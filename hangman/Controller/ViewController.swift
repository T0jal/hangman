//
//  ViewController.swift
//  hangman
//
//  Created by António Rocha on 19/11/2021.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var clueLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var heart0: UIButton!
    @IBOutlet weak var heart1: UIButton!
    @IBOutlet weak var heart2: UIButton!
    @IBOutlet weak var heart3: UIButton!
    @IBOutlet weak var heart4: UIButton!
    @IBOutlet weak var heart5: UIButton!
    @IBOutlet weak var heart6: UIButton!
    @IBOutlet weak var guessButton: UIButton!
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var heartsArray = [UIButton]()
    var triesLeft = 7 {
        didSet {
            for heart in heartsArray {
                if heart.tag == triesLeft {
                    heart.isHidden = true
                }
            }
        }
    }

    var questionNumber = 0
    
    var hiddenAnswerArray = [String]()
    var hiddenAnswer = "" {
        didSet {
            answerLabel.text = hiddenAnswer
        }
    }
    
    var cluesArray = [String]()
    var answersArray = [String]()
    var guessLetter = ""
    var arrayOfLettersFromAnswer = [String]()
    var usedCharacters = [String]()
    var correctGuesses = [String]()
    
//MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        heartsArray = [heart0, heart1, heart2, heart3, heart4, heart5, heart6]
        
        scoreLabel.text = "Score: 0"
        
        guessButton.backgroundColor = .green
        guessButton.tintColor = .black
        guessButton.layer.cornerRadius = 5
        guessButton.layer.borderWidth = 1
        guessButton.layer.borderColor = UIColor.green.cgColor
        guessButton.addTarget(self, action: #selector(askForLetter), for: .touchUpInside)
        
        performSelector(inBackground: #selector(loadGameData), with: nil)
    }
 
//MARK: - Load Level + Change Level
        
    @objc func loadGameData() {
        
        if let gameDataFileURL = Bundle.main.url(forResource: "gameData", withExtension: "txt") {
            if let gameDataContents = try? String(contentsOf: gameDataFileURL) {
                var lines = gameDataContents.components(separatedBy: "\n")
                lines.shuffle()
                for line in lines {
                    let parts = line.components(separatedBy: ": ")
                    let answer = parts[0]
                    let clue = parts[1]
                    
                    answersArray.append(answer)
                    cluesArray.append(clue)
                }
            }
        }
        performSelector(onMainThread: #selector(populateElements), with: nil, waitUntilDone: false)
    }
    
    @objc func populateElements() {

        clueLabel.text = cluesArray[questionNumber]
        for (index, letter) in answersArray[questionNumber].enumerated() {
            if index == answersArray.count-1 {
                hiddenAnswerArray.append("_")
            } else {
                hiddenAnswerArray.append("_ ")
            }
            arrayOfLettersFromAnswer.append(String(letter))
        }
        fillHiddenAnswer(guessLetter)
    }
    
    func fillHiddenAnswer(_ guessLetter: String) {
        hiddenAnswer = ""
        for (index, letter) in arrayOfLettersFromAnswer.enumerated() {
            if guessLetter == letter {
                hiddenAnswerArray[index] = guessLetter
            }
        }
        for element in hiddenAnswerArray {
            hiddenAnswer += element
        }
        answerLabel.text = hiddenAnswer
    }
    
    func nextQuestion(action: UIAlertAction) {
        questionNumber += 1
        score += 1
        clear()
    }
    
    func newGame(action: UIAlertAction) {
        questionNumber = 0
        score = 0
        clear()
    }
    
    func clear() {
        triesLeft = 7
        guessLetter = ""
        arrayOfLettersFromAnswer.removeAll()
        usedCharacters.removeAll()
        hiddenAnswerArray.removeAll()
        for heart in heartsArray {
            heart.isHidden = false
        }
        populateElements()
    }

    //MARK: - Ask for letter
    
    @objc func askForLetter() {
        let ac = UIAlertController(title: "Enter a letter", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "try", style: .default) {
            [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit (_ answer: String) {
        guessLetter = answer.capitalized
        if isEmpty(this: guessLetter) {
            if isOnlyOneLetter(this: guessLetter) {
                if isOriginal(this: guessLetter) {
                    if isPresent(this: guessLetter) {
                        usedCharacters.append(guessLetter)
                        correctGuesses.append(guessLetter)
                        fillHiddenAnswer(guessLetter)
                        if hiddenAnswer.count == answersArray[questionNumber].count {
                            if questionNumber != answersArray.count-1 {
                                let ac = UIAlertController(title: "Well done!", message: "Are you ready for the next level?", preferredStyle: .alert)
                                ac.addAction(UIAlertAction(title: "Let's go!", style: .default, handler: nextQuestion))
                                present(ac, animated: true)
                            } else {
                                let ac = UIAlertController(title: "You are the champion!", message: "You completed the game. Go celebrate!", preferredStyle: .alert)
                                ac.addAction(UIAlertAction(title: "Thanks!", style: .default, handler: nil))
                                present(ac, animated: true)
                            }
                        }
                    } else {
                        triesLeft -= 1
                        showErrorMessage(errorTitle: "Not this one...", errorMessage: "The word doesn't contain this letter.")
                    }
                } else {
                    showErrorMessage(errorTitle: "This one again?", errorMessage: "You already tried this letter.")
                }
            } else {
                showErrorMessage(errorTitle: "That's not one letter", errorMessage: "You typed more than one letter.")
            }
        } else {
            showErrorMessage(errorTitle: "You forgot to type", errorMessage: "The textbox was empty.")
        }
            
    }
      
    func isEmpty(this guessLetter: String) -> Bool {
        return guessLetter.isEmpty ? false : true
    }
    
    func isOnlyOneLetter(this guessLetter: String) -> Bool {
        return guessLetter.count == 1 ? true : false
    }
    
    func isOriginal(this guessLetter: String) -> Bool {
        return !usedCharacters.contains(guessLetter)
    }
    
    func isPresent(this guessLetter: String) -> Bool {
        return arrayOfLettersFromAnswer.contains(guessLetter)
    }
    
    func showErrorMessage(errorTitle: String, errorMessage: String) {
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: gameOver))
        present(ac, animated: true)
    }
    
    func gameOver(action: UIAlertAction) {
        if triesLeft == 0 {
            let ac = UIAlertController(title: "Ups!", message: "You lost all your hearts. Ready to go again?", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Let's go!", style: .default, handler: newGame))
            present(ac, animated: true)
        }
    }
}
