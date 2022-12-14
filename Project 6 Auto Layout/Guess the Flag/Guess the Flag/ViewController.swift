//
//  ViewController.swift
//  Guess the Flag
//
//  Created by Nikita Novikov on 01.10.2022.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    
    var countries: [String] = []
    var score = 0
    var correctAnswer = 0
    var askedQuestionsCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
        
        configureButton(button: button1)
        configureButton(button: button2)
        configureButton(button: button3)
        
        createNavigationBarButton()
        
        askQuestion()
    }
    
    private func createNavigationBarButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Score", style: .plain, target: self, action: #selector(showScore))
    }
    
    private func configureButton(button: UIButton) {
//        var configuration = UIButton.Configuration.plain()
//        configuration.contentInsets = .zero
//        configuration.imagePadding = .zero
//        button.configuration = configuration
        
        button.layer.borderWidth = 1
        button.imageEdgeInsets = .zero
        button.layer.borderColor = UIColor.gray.cgColor
    }

    func askQuestion(action: UIAlertAction! = nil) {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        
        let countryToGuess = countries[correctAnswer].uppercased()
        title = "\(countryToGuess) Score: \(score)"
    }
    
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        askedQuestionsCount += 1
        if sender.tag == correctAnswer {
            score += 1
        } else {
            score -= 1
        }
        
        if askedQuestionsCount == 10 {
            showFinalAlert(score: score)
            
            askedQuestionsCount = 0
            score = 0
        } else {
            showQuestionAnsweredAlert(isCorrect: sender.tag == correctAnswer, usersChose: sender.tag)
        }
    }
    
    private func showQuestionAnsweredAlert(isCorrect: Bool, usersChose: Int) {
        var title: String
        
        if isCorrect {
            title = "Correct"
        } else {
            title = "Wrong! That???s the flag of \(countries[usersChose].uppercased())"
        }
        
        let ac = UIAlertController(title: title, message: "Your score is \(score)", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
        
        present(ac, animated: true)
    }
    
    private func showFinalAlert(score: Int) {
        let ac = UIAlertController(title: "GAME IS OVER", message: "Your score is \(score)", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Try again!", style: .default, handler: askQuestion))
        
        present(ac, animated: true)
    }
    
    @objc private func showScore() {
        let alert = UIAlertController(title: "Your score is \(score)", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
        present(alert, animated: true)
    }
}

