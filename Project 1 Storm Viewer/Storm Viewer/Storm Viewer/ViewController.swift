//
//  ViewController.swift
//  Storm Viewer
//
//  Created by Nikita Novikov on 01.10.2022.
//

import UIKit

class ViewController: UITableViewController {
    var pictures: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Storm viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sharedTapped))
        
        performSelector(inBackground: #selector(loadResources), with: nil)
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let imgspath = paths[0].appending(component: "Images")
        let imgPath = imgspath.appending(path: "Storm Viewer")
        
        let image = UIImage(named: "nssl0049.jpg")!
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imgPath)
        }
    }
    
    @objc func loadResources() {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        for item in items {
            if item.hasPrefix("nssl") {
                pictures.append(item)
            }
        }
        
        pictures.sort(by: <)
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        var configuration = cell.defaultContentConfiguration()
        configuration.textProperties.font = UIFont.preferredFont(forTextStyle: .headline)
        configuration.text = pictures[indexPath.row]
        cell.contentConfiguration = configuration
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.selectedImage = pictures[indexPath.row]
            vc.pictureIndex = indexPath.row + 1
            vc.allPicturesCount = pictures.count
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func sharedTapped() {
        let message = "Try my UIKit app: https://github.com/sirpointer/Storm-Viewer-UIKit"
        
        let vc = UIActivityViewController(activityItems: [message], applicationActivities: [])
        
        if let popover = vc.popoverPresentationController {
            popover.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popover.sourceView = self.view
            popover.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }
        
        present(vc, animated: true)
    }
}

