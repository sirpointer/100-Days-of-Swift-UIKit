//
//  ViewController.swift
//  Storm Viewer
//
//  Created by Nikita Novikov on 01.10.2022.
//

import UIKit

class ViewController: UICollectionViewController {
    var pictures: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Storm viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sharedTapped))
        
        performSelector(inBackground: #selector(loadResources), with: nil)
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
            self?.collectionView.reloadData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pictures.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Picture", for: indexPath) as? PictureCollectionViewCell else {
            fatalError()
        }
        
        let picture = pictures[indexPath.item]
        cell.image.image = UIImage(named: picture)
        cell.image.layer.cornerRadius = 7
        cell.text.text = picture
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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

