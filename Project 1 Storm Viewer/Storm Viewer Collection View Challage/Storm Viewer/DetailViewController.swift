//
//  DetailViewController.swift
//  Storm Viewer
//
//  Created by Nikita Novikov on 01.10.2022.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    var selectedImage: String?
    var pictureIndex: Int?
    var allPicturesCount: Int?
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
    
    @objc func sharedTapped() {
        guard let selectedImage = selectedImage,
              let image = getImageForSharing()?.jpegData(compressionQuality: 0.8) else {
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
    
    func getImageForSharing() -> UIImage? {
        guard let image = imageView.image else { return nil }
        
        let size = image.size
        let renderer = UIGraphicsImageRenderer(size: size)
        let renderedImage = renderer.image { ctx in
            image.draw(at: .zero)
            
            let waterMarkString = "Storm Viewer\ngithub.com/sirpointer/100-Days-of-Swift-UIKit"
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let font = UIFont.systemFont(ofSize: size.height * 0.05)
            let fontHeight = font.lineHeight
            let lineSpacing = paragraphStyle.lineSpacing
            
            let stringShadow = NSShadow()
            stringShadow.shadowColor = UIColor.darkGray
            stringShadow.shadowBlurRadius = 2
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor(red: 1, green: 1, blue: 1, alpha: 0.7),
                .shadow: stringShadow,
            ]
            
            let y = size.height - fontHeight * 2.0 - lineSpacing - size.height * 0.01
            
            let attrString = NSAttributedString(string: waterMarkString, attributes: attrs)
            attrString.draw(in: CGRect(origin: CGPoint(x: 0, y: y), size: size))
        }
        
        return renderedImage
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
