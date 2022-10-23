//
//  ViewController.swift
//  Flag Challenge
//
//  Created by Nikita Novikov on 03.10.2022.
//

import UIKit

class FlagTableViewController: UITableViewController {
    
    var flags: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bandlePath = Bundle.main.resourcePath!
        let contents = try! FileManager.default.contentsOfDirectory(atPath: bandlePath)
        
        for content in contents {
            if content.hasSuffix(".png") {
                flags.append(content)
            }
        }
        
        flags.sort(by: <)
        
        tableView.backgroundColor = UIColor(named: "backgroundColor")
        navigationItem.title = "Flags"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.standardAppearance.backgroundColor = UIColor(named: "backgroundColor")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        flags.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Flag", for: indexPath)
        
        let flag = flags[indexPath.row]
        var configuration = cell.defaultContentConfiguration()
        configuration.text = flag.flagName
        configuration.image = UIImage(named: flag)
        configuration.imageProperties.cornerRadius = 5
        configuration.imageProperties.maximumSize = CGSize(width: 70, height: 35)
        cell.contentConfiguration = configuration
        
        cell.backgroundColor = UIColor(named: "backgroundColor")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let detailView = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            detailView.selectedImageName = flags[indexPath.row]
            navigationController?.pushViewController(detailView, animated: true)
        }
    }
}


extension String {
    var flagName: String {
        self.components(separatedBy: ".")[0].capitalized
    }
}
