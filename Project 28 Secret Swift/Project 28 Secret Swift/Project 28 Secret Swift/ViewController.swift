//
//  ViewController.swift
//  Project 28 Secret Swift
//
//  Created by Nikita Novikov on 04.11.2022.
//

import UIKit
import SwiftKeychainWrapper
import LocalAuthentication

class ViewController: UIViewController {
    @IBOutlet var secret: UITextView!
    
    private var doneBarButtonItem: UIBarButtonItem!
    
    private let authenticationFailedMessage = "You could not be verified; Please try again."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Nothing to see here"
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
        
        doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveSecretMessage))
        navigationItem.rightBarButtonItem = doneBarButtonItem
        doneBarButtonItem.isHidden = true
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardScreenEnd = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEnd, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            secret.contentInset = .zero
        } else {
            secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        secret.scrollIndicatorInsets = secret.contentInset
        
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }
    
    @IBAction func authenticateTapped(_ sender: Any) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self?.unlockSecretMessage()
                    } else {
                        let ac = UIAlertController(title: "Authentication failed", message: self?.authenticationFailedMessage, preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "Ok", style: .default))
                        self?.present(ac, animated: true)
                    }
                }
            }
        } else {
            usePassword()
        }
    }
    
    func usePassword() {
        let loadedPassword = loadPassword()
        
        if let loadedPassword = loadedPassword {
            unlockWithPassword(loadedPassword)
        } else {
            setNewPassword()
        }
    }
    
    func setNewPassword() {
        let ac = UIAlertController(title: "Set a password to keep your data safety", message: nil, preferredStyle: .alert)
        ac.addTextField(configurationHandler: { textField in
            textField.isSecureTextEntry = true
        })
        let action = UIAlertAction(title: "Ok", style: .default) { [weak self, weak ac] alertAction in
            let text = ac?.textFields?[0].text ?? ""
            self?.savePassword(text)
            self?.unlockSecretMessage()
        }
        ac.addAction(action)
        present(ac, animated: true)
    }
    
    func unlockWithPassword(_ loadedPassword: String) {
        let ac = UIAlertController(title: "Identify yourself!", message: "Enter the password", preferredStyle: .alert)
        ac.addTextField(configurationHandler: { textField in
            textField.isSecureTextEntry = true
        })
        let action = UIAlertAction(title: "Confirm", style: .default) { [weak self, weak ac] alertAction in
            guard let text = ac?.textFields?[0].text,
                  text == loadedPassword else {
                      DispatchQueue.main.async {
                          self?.incorrectPasswordAlert()
                      }
                      return
                  }
            
            self?.unlockSecretMessage()
        }
        ac.addAction(action)
        present(ac, animated: true)
    }
    
    func incorrectPasswordAlert() {
        let ac = UIAlertController(title: "Incorrect password", message: authenticationFailedMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
    }
    
    
    func loadPassword() -> String? {
        KeychainWrapper.standard.string(forKey: "Password")
    }
    
    func savePassword(_ password: String) {
        KeychainWrapper.standard.set(password, forKey: "Password")
    }
    
    func unlockSecretMessage() {
        secret.isHidden = false
        doneBarButtonItem.isHidden = false
        title = "Secret staff!"
        
        secret.text = KeychainWrapper.standard.string(forKey: "SecretMessage") ?? ""
    }
    
    @objc func saveSecretMessage() {
        guard !secret.isHidden else { return }
        
        KeychainWrapper.standard.set(secret.text, forKey: "SecretMessage")
        secret.resignFirstResponder()
        secret.isHidden = true
        doneBarButtonItem.isHidden = true
        title = "Nothing to see here"
    }
}
