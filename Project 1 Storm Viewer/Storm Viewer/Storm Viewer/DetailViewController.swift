//
//  DetailViewController.swift
//  Storm Viewer
//
//  Created by Nikita Novikov on 01.10.2022.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    var currentShownCountLabel: UILabel!
    
    
    var selectedImage: String?
    var pictureIndex: Int?
    var allPicturesCount: Int?
    
    var currentShownCount: Int? {
        didSet {
            if let currentShownCount = currentShownCount {
                currentShownCountLabel.text = String(currentShownCount)
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        
        currentShownCountLabel = UILabel()
        currentShownCountLabel.translatesAutoresizingMaskIntoConstraints = false
        currentShownCountLabel.layer.zPosition = imageView.layer.zPosition + 1
        view.addSubview(currentShownCountLabel)
        
        NSLayoutConstraint.activate([
            currentShownCountLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            currentShownCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let pictureIndex = pictureIndex, let allPicturesCount = allPicturesCount {
            title = "Picture \(pictureIndex) of \(allPicturesCount)"
        }
        navigationItem.largeTitleDisplayMode = .never
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sharedTapped))
        
        if let imageToLoad = selectedImage {
            imageView.image = UIImage(named: imageToLoad)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let selectedImage = selectedImage else { return }
        let currentShownCount = UserDefaults.standard.integer(forKey: selectedImage) + 1
        UserDefaults.standard.set(currentShownCount, forKey: selectedImage)
        
        self.currentShownCount = currentShownCount
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
    
    @objc func sharedTapped() {
        guard let image = imageView.image?.jpegData(compressionQuality: 1),
              let selectedImage = selectedImage else {
            print("No image found")
            return
        }
        
        let vc = UIActivityViewController(activityItems: [image, selectedImage], applicationActivities: [])
        
        if let popover = vc.popoverPresentationController {
            popover.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popover.sourceView = self.view
            popover.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }
        
        present(vc, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
