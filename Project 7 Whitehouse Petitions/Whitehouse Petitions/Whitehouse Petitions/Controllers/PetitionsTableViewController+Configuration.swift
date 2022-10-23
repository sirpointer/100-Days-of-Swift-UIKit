//
//  PetitionsTableViewController+Configuration.swift
//  Whitehouse Petitions
//
//  Created by Nikita Novikov on 16.10.2022.
//

import Foundation
import UIKit

extension PetitionTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let petition = dataSource[indexPath.row]
        
        var configuration = cell.defaultContentConfiguration()
        configuration.text = petition.title
        configuration.textProperties.numberOfLines = 1
        configuration.secondaryText = petition.body
        configuration.secondaryTextProperties.numberOfLines = 1
        cell.contentConfiguration = configuration
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = petitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}
