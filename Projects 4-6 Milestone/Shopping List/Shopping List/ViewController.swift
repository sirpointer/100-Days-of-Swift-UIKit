//
//  ViewController.swift
//  Shopping List
//
//  Created by Nikita Novikov on 14.10.2022.
//

import UIKit

class ShoppingListController: UITableViewController {
    
    private var shoppingList: [String] = []
    private var shoppingListFilePath: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathExtension("ShoppingList.json")
    }
    
    func loadShoppingList() -> [String] {
        if let jsonString = try? String(contentsOf: shoppingListFilePath),
           let jsonStringData = jsonString.data(using: .utf8),
           let list = try? JSONDecoder().decode([String].self, from: jsonStringData) {
            return list
        }
        return []
    }
    
    func saveShoppingList() {
        if let jsonData = try? JSONEncoder().encode(shoppingList),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            try? jsonString.write(to: shoppingListFilePath, atomically: true, encoding: .utf8)
        }
    }
    
    @objc func addNewItemBarButtonAction() {
        let ac = UIAlertController(title: "New item", message: "What do you want to add in the list.", preferredStyle: .alert)
        ac.addTextField()
        let confirmButton = UIAlertAction(title: "Add", style: .default, handler: { [weak self, weak ac] action in
            if let text = ac?.textFields?.first?.text {
                self?.addNewItem(name: text)
            }
        })
        ac.addAction(confirmButton)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func addNewItem(name: String) {
        let clearName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !clearName.isEmpty && !shoppingList.contains(where: { $0.lowercased() == clearName.lowercased() }) {
            appendNewItem(name: clearName)
        }
    }
    
    func removeItem(at indexPath: IndexPath) {
        shoppingList.remove(at: indexPath.row)
        
        DispatchQueue.main.async {
            self.saveShoppingList()
        }
        
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func appendNewItem(name: String) {
        shoppingList.insert(name, at: 0)
        DispatchQueue.main.async {
            self.saveShoppingList()
        }
        
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    @objc func clearListBarButtonAction() {
        let ac = UIAlertController(title: "Clear list", message: "Do you want to clear all list items?", preferredStyle: .actionSheet)
        let clear = UIAlertAction(title: "Clear", style: .destructive, handler: { [weak self] _ in
            self?.clearList()
        })
        ac.addAction(clear)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func clearList() {
        shoppingList = []
        saveShoppingList()
        tableView.reloadData()
    }
    
    func getShoppingListDateForSharing() -> String? {
        shoppingList.joined(separator: "\n")
    }
    
    @objc func shareBarButtonAction() {
        guard let sharedData = getShoppingListDateForSharing() else { return }
        let avc = UIActivityViewController(activityItems: [sharedData], applicationActivities: nil)
        present(avc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.shoppingList = self.loadShoppingList()
            self.tableView.reloadData()
        }
        
        let addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewItemBarButtonAction))
        let clearBarButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(clearListBarButtonAction))
        clearBarButton.tintColor = .red
        navigationItem.rightBarButtonItems = [addBarButton, clearBarButton]
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Share", image: UIImage(systemName: "square.and.arrow.up"), target: self, action: #selector(shareBarButtonAction))
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shoppingList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Item", for: indexPath)
        var configuration = cell.defaultContentConfiguration()
        configuration.text = shoppingList[indexPath.row]
        cell.contentConfiguration = configuration
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Remove", handler: { [weak self] action, sourceView, completion  in
            self?.removeItem(at: indexPath)
            completion(true)
        })
        action.image = UIImage(systemName: "trash")
        let swipe = UISwipeActionsConfiguration(actions: [action])
        return swipe
    }
}
