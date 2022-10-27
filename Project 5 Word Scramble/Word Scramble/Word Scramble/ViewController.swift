//
//  ViewController.swift
//  Word Scramble
//
//  Created by Nikita Novikov on 13.10.2022.
//

import UIKit

class ViewController: UITableViewController {
    var allWords: [String] = []
    var usedWords: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reloadGame))
        
        if let startWordsUrl = Bundle.main.url(forResource: "start", withExtension: "txt"),
           let startWords = try? String(contentsOf: startWordsUrl) {
            allWords = startWords.components(separatedBy: "\n")
        } else {
            allWords = ["silkworm"]
        }
        
        startGame(isNew: true)
    }

    func startGame(isNew: Bool) {
        if isNew, let loaded = loadData() {
            title = loaded.current
            usedWords = loaded.used
        } else {
            let current = allWords.randomElement()
            title = current
            usedWords.removeAll(keepingCapacity: true)
        }
        
        tableView.reloadData()
    }
    
    @objc func reloadGame() {
        saveData(current: nil, used: [])
        startGame(isNew: false)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        var configuration = cell.defaultContentConfiguration()
        configuration.text = usedWords[indexPath.row]
        cell.contentConfiguration = configuration
        return cell
    }

    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter Answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    var currentWord: String? {
        title?.lowercased()
    }
    
    func submit(_ answer: String) {
        let lowerAnwer = answer.lowercased()
        let errorTitle: String
        let errorMessage: String
        
        if isPossible(word: lowerAnwer) {
            if isOriginal(word: lowerAnwer) {
                if isReal(word: lowerAnwer) {
                    usedWords.insert(answer, at: 0)
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    saveData(current: currentWord, used: usedWords)
                    
                    return
                } else {
                    errorTitle = "Word not recognised"
                    errorMessage = "You can't just make them up, you know!"
                }
            } else {
                errorTitle = "Word used already"
                errorMessage = "Be more original!"
            }
        } else {
            guard let title = currentWord else { return }
            errorTitle = "Word not possible"
            errorMessage = "You can't spell that word from \(title)"
        }
        
        showErrorMessage(title: errorTitle, message: errorMessage)
    }
    
    func showErrorMessage(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = currentWord else { return false }
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                 return false
            }
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(where: { $0.lowercased() == word.lowercased() })
    }
    
    func isReal(word: String) -> Bool {
        if word.count < 3 {
            return false
        } else if let currentWord = currentWord,
                  word.lowercased() == currentWord {
            return false
        }
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    
    func saveData(current: String?, used: [String]) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(current, forKey: "Current word")
        userDefaults.set(used, forKey: "Used words")
    }
    
    func loadData() -> (current: String, used: [String])? {
        let userDefaults = UserDefaults.standard
        if let current = userDefaults.string(forKey: "Current word"),
           let usedWords = userDefaults.array(forKey: "Used words") as? [String] {
            return (current, usedWords)
        }
        
        return nil
    }
}
