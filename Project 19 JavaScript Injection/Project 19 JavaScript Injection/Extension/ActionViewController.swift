//
//  ActionViewController.swift
//  Extension
//
//  Created by Nikita Novikov on 31.10.2022.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class ActionViewController: UIViewController {

    @IBOutlet var script: UITextView!
    
    var pageTitle = ""
    var pageURL = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "applescript"), style: .plain, target: self, action: #selector(showJSListAlert))
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = inputItem.attachments?.first {
                itemProvider.loadItem(forTypeIdentifier: UTType.propertyList.identifier) { [weak self] (dict, error) in
                    guard let itemDictionary = dict as? NSDictionary else { return }
                    guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                    
                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                    self?.pageURL = javaScriptValues["URL"] as? String ?? ""
                    
                    DispatchQueue.main.async {
                        self?.title = self?.pageTitle
                        self?.script.text = self?.load() ?? ""
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        save()
    }

    @IBAction func done() {
        executeScript(scriptText: script.text ?? "")
    }
    
    @objc private func showJSListAlert() {
        let ac = UIAlertController(title: "Choose script", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Show document title", style: .default, handler: { [weak self] _ in
            self?.showDocumentTitleAlert()
        }))
        ac.addAction(UIAlertAction(title: "Show page info", style: .default, handler: { [weak self] _ in
            self?.showDocumentInfoAlert()
        }))
        ac.addAction(UIAlertAction(title: "Show developer info", style: .default, handler: { [weak self] _ in
            self?.showDeveloperInfo()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    func executeScript(scriptText: String) {
        let item = NSExtensionItem()
        let argument: NSDictionary = ["customJavaScript": scriptText]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJS = NSItemProvider(item: webDictionary, typeIdentifier: UTType.propertyList.identifier)
        item.attachments = [customJS]
        extensionContext?.completeRequest(returningItems: [item])
    }
    
    private func showDocumentTitleAlert() {
        executeScript(scriptText: "alert(document.title)")
    }
    
    private func showDocumentInfoAlert() {
        let alertText = "\(pageTitle). \(pageURL)"
        executeScript(scriptText: "alert('\(alertText)')")
    }
    
    private func showDeveloperInfo() {
        executeScript(scriptText: "alert('Nikita Novikov:  https://github.com/sirpointer')")
    }
    
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            script.contentInset = .zero
        } else {
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        script.scrollIndicatorInsets = script.contentInset
        
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
    }
    
    
    private func save() {
        guard let scriptText = script.text else { return }
        let trimmedScript = scriptText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedScript.isEmpty,
              let urlComponents = URLComponents(string: pageURL),
              let host = urlComponents.host else {
            return
        }
        
        let defaults = UserDefaults.standard
        defaults.set(trimmedScript, forKey: host)
    }
    
    private func load() -> String? {
        guard let urlComponents = URLComponents(string: pageURL),
              let host = urlComponents.host else {
            return nil
        }
        
        return UserDefaults.standard.string(forKey: host)
    }
}
