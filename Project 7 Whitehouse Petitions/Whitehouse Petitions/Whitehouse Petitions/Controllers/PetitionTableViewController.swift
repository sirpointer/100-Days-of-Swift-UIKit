//
//  ViewController.swift
//  Whitehouse Petitions
//
//  Created by Nikita Novikov on 15.10.2022.
//

import UIKit

class PetitionTableViewController: UITableViewController {
    var petitions: [Petition] = []
    var filteredPetitions: [Petition] {
        petitions.filter { $0.title.lowercased().contains(searchText.lowercased()) }
    }
    
    var searchText: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var dataSource: [Petition] {
        searchText.isEmpty ? petitions : filteredPetitions
        //filteredPetitions.isEmpty ? petitions : filteredPetitions
    }
    
    private var dataTask: URLSessionDataTask? = nil
    private var dataSourceURLString: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPetitions()
    }
    
    func loadPetitions() {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "www.hackingwithswift.com"
        
        if navigationController?.tabBarItem.tag == 0 {
            urlComponents.path = "/samples/petitions-1.json"
        } else {
            urlComponents.path = "/samples/petitions-2.json"
        }
        
        dataSourceURLString = urlComponents.url?.absoluteString
        
        if let url = urlComponents.url {
            dataTask?.cancel()
            dataTask = URLSession.shared.dataTask(with: URLRequest(url: url), completionHandler: { [weak self] data, response, error in
                defer {
                    self?.dataTask = nil
                }
                
                if let error = error {
                    print(error.localizedDescription)
                    self?.showError()
                    return
                }
                
                if let data = data {
                    self?.parseAndSetPetitions(jsonData: data)
                }
            })
            dataTask?.resume()
        } else {
            showError()
        }
        
        if dataSourceURLString != nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(showCredits))
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchPetitions))
        }
    }
    
    func parseAndSetPetitions(jsonData: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: jsonData) {
            DispatchQueue.main.async {
                self.petitions = jsonPetitions.results
                self.tableView.reloadData()
            }
        } else {
            showError()
        }
    }
    
    func showError() {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try againg", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
            self.present(ac, animated: true)
        }
    }
    
    @objc func showCredits() {
        let ac = UIAlertController(title: "Credits", message: "This data came from \(dataSourceURLString ?? "")", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
    }
    
    @objc func searchPetitions() {
        let ac = UIAlertController(title: "Seach", message: nil, preferredStyle: .alert)
        ac.addTextField(configurationHandler: { [weak self] tf in
            tf.text = self?.searchText
        })
        
        let searchButton = UIAlertAction(title: "Search", style: .default, handler: { [weak self, weak ac] alertAction in
            if let text = ac?.textFields?.first?.text,
               let validText = self?.getValidSearchText(text: text) {
                self?.searchText = validText
            }
        })
        
        ac.addAction(searchButton)
        ac.addAction(UIAlertAction(title: "Clear", style: .default, handler: { [weak self] _ in
            self?.searchText = ""
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    func getValidSearchText(text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty ? trimmed : nil
    }
}

