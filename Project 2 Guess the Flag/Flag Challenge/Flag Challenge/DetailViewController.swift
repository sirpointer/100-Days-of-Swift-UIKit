//
//  DetailViewController.swift
//  Flag Challenge
//
//  Created by Nikita Novikov on 08.10.2022.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var flagImage: UIImageView!
    var selectedImageName: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let selectedImageName = selectedImageName {
            flagImage.image = UIImage(named: selectedImageName)
            navigationItem.title = selectedImageName.flagName
        }
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = UIColor(named: "backgroundColor")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareAction))
    }
    
    @objc private func shareAction() {
        guard let image = flagImage.image?.jpegData(compressionQuality: 1.0),
              let selectedImageName = selectedImageName,
              let bounds = view.window?.windowScene?.screen.bounds else {
            return
        }
        
        let activityViewController = UIActivityViewController(activityItems: [image, selectedImageName.flagName], applicationActivities: [])
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceRect = CGRect(x: bounds.width / 2, y: bounds.height / 2, width: 0, height: 0)
            popover.sourceView = view
            popover.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }
        
        present(activityViewController, animated: true)
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
