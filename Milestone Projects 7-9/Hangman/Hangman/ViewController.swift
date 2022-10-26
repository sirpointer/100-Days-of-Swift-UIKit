//
//  ViewController.swift
//  Hangman
//
//  Created by Nikita Novikov on 24.10.2022.
//

import UIKit

extension StringProtocol {
    subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
}


final class ViewController: UIViewController {
    
    private var lettersButtons: Dictionary<String, UIButton> = [:]
    private var scoreLabel: UILabel!
    private var wrongAnswersLabel: UILabel!
    private var wordLabel: UILabel!
    private var resetButton: UIButton!
    
    private var wordForGuess: String = ""
    private let wrongLimit = 7
    private var score: Int = 0 {
        didSet {
            scoreLabel.text = getScoreLabelText(score: score)
        }
    }
    private var wrongAnswersCount: Int = 0 {
        didSet {
            wrongAnswersLabel.text = getWrongAnswersLabelText(wrongAnswersCount)
            wrongAnswersLabel.textColor = getWrongAnswersLabelColor(wrongAnswersCount)
        }
    }
    
    
    private func getScoreLabelText(score: Int) -> String {
        "Score: \(score)"
    }
    
    private func getWrongAnswersLabelText(_ value: Int) -> String {
        "Attempts: \(wrongLimit - value)"
    }
    
    private func getWrongAnswersLabelColor(_ value: Int) -> UIColor {
        return wrongLimit - value < 3 ? .red : UIColor.label
    }
    
    
    override func loadView() {
        super.loadView()
        
        let frame = view.frame
        let minSide = [frame.width, frame.height].min()!
        let letterButtonsViewWidth = minSide * 0.95
        let letterButtonsViewHeight = minSide * 0.5
        
        scoreLabel = UILabel()
        scoreLabel.text = getScoreLabelText(score: score)
        scoreLabel.font = UIFont.systemFont(ofSize: 16)
        scoreLabel.textAlignment = .center
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scoreLabel)
        
        wrongAnswersLabel = UILabel()
        wrongAnswersLabel.text = getWrongAnswersLabelText(wrongAnswersCount)
        wrongAnswersLabel.font = UIFont.systemFont(ofSize: 16)
        wrongAnswersLabel.textAlignment = .center
        wrongAnswersLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(wrongAnswersLabel)
        
        wordLabel = UILabel()
        wordLabel.font = UIFont.systemFont(ofSize: 24)
        wordLabel.text = "????????"
        wordLabel.textAlignment = .center
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        wordLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(wordLabel)
        
        resetButton = UIButton(type: .system)
        resetButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.addTarget(self, action: #selector(reloadButtonTapped), for: .touchDown)
        view.addSubview(resetButton)
        
        let letterButtonsView = UIView()
        letterButtonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(letterButtonsView)
        
        NSLayoutConstraint.activate([
            resetButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            resetButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scoreLabel.centerYAnchor.constraint(equalTo: resetButton.centerYAnchor),
            
            wrongAnswersLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 30),
            wrongAnswersLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            wordLabel.topAnchor.constraint(equalTo: wrongAnswersLabel.bottomAnchor, constant: 40),
            wordLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            letterButtonsView.topAnchor.constraint(equalTo: wordLabel.bottomAnchor),
            letterButtonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            letterButtonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            letterButtonsView.heightAnchor.constraint(equalToConstant: letterButtonsViewHeight),
            letterButtonsView.widthAnchor.constraint(equalToConstant: letterButtonsViewWidth)
        ])
        
        
        let lettersUnicodeScalars = UInt32("A")...UInt32("Z")
        let letters = String(String.UnicodeScalarView(lettersUnicodeScalars.compactMap(UnicodeScalar.init)))
        
        let isPhone = UIDevice.current.userInterfaceIdiom == .phone
        let rowsCount = isPhone ? 4 : 3
        let lettersInRow = letters.count / (isPhone ? 4 : 3)
        
        for row in 0..<rowsCount {
            let end = row < (rowsCount - 1) ? (row + 1) * lettersInRow : letters.count
            let start = row * lettersInRow
            let columnsRange = start..<end
            
            for letterIndex in columnsRange {
                let letter = String(letters[letters.index(letters.startIndex, offsetBy: letterIndex)])
                
                let indexInRow = letterIndex - start
                let lettersInRow = columnsRange.count
                let width = letterButtonsViewWidth / CGFloat(lettersInRow)
                let height = letterButtonsViewHeight / CGFloat(rowsCount)
                
                let button = UIButton(type: .system)
                button.setTitle(letter, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
                button.addTarget(self, action: #selector(letterButtonTapped), for: .touchDown)
                
                button.frame = CGRect(x: CGFloat(indexInRow) * width, y: CGFloat(row) * height, width: width, height: height)
                
                letterButtonsView.addSubview(button)
                lettersButtons[letter] = button
            }
        }
        
        performSelector(inBackground: #selector(loadWord), with: nil)
    }
    
    @objc private func loadWord() {
        if let wordsFileUrl = Bundle.main.url(forResource: "List of words", withExtension: "txt"),
           let content = try? String(contentsOf: wordsFileUrl).components(separatedBy: "\n"),
           let randomWord = content.randomElement() {
            DispatchQueue.main.async { [unowned self] in
                self.startGame(for: randomWord)
            }
        } else {
            DispatchQueue.main.async { [unowned self] in
                self.presentCannotLoadGame()
            }
        }
    }
    
    private func startGame(for word: String) {
        wrongAnswersCount = 0
        wordForGuess = word
        wordLabel.text = word.map { _ in "?" }.joined()
        
        for button in lettersButtons {
            button.value.isHidden = false
        }
    }
    
    private func startAgain() {
        wrongAnswersCount = 0
        performSelector(inBackground: #selector(loadWord), with: nil)
    }
    
    
    @objc private func letterButtonTapped(_ sender: UIButton) {
        guard let letter = sender.titleLabel?.text?.uppercased(),
              let currentWord = wordLabel.text else {
            return
        }
        sender.isHidden = true
        
        if wordForGuess.contains(where: { String($0).uppercased() == letter }) {
            var newWord = ""
            for letterFromWord in wordForGuess.uppercased().enumerated() {
                if String(letterFromWord.element) == letter {
                    newWord.append(letter)
                } else {
                    newWord.append(String(currentWord[letterFromWord.offset]))
                }
            }
            wordLabel.text = newWord
            wrongAnswersCount -= 1
            
            if !newWord.contains(where: { String($0) == "?" }) {
                score += 1
                presentWin()
            }
        } else {
            wrongAnswersCount += 1
        }
        
        if wrongAnswersCount >= wrongLimit {
            presentOutOfWrongLimit()
            score -= 1
        }
    }
    
    @objc private func reloadButtonTapped() {
        score -= 1
        startAgain()
    }
    
    
    private func presentWin() {
        let ac = UIAlertController(title: "You won!", message: wordForGuess.uppercased(), preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: { [unowned self] _ in
            DispatchQueue.main.async { [unowned self] in
                self.startAgain()
            }
        }))
        present(ac, animated: true)
    }
    
    private func presentOutOfWrongLimit() {
        let ac = UIAlertController(title: "You're lose!", message: wordForGuess.uppercased(), preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Try again!", style: .default, handler: { [unowned self] _ in
            DispatchQueue.main.async {
                self.startAgain()
            }
        }))
        present(ac, animated: true)
    }
    
    private func presentCannotLoadGame() {
        let ac = UIAlertController(title: "Cannot load game :(", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(ac, animated: true)
    }
}
