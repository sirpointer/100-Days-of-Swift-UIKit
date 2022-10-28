//
//  ViewController.swift
//  Project 15 Animation
//
//  Created by Nikita Novikov on 28.10.2022.
//

import UIKit

class ViewController: UIViewController {
    var imageView: UIImageView!
    var currentAnimation = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        imageView = UIImageView(image: UIImage(named: "penguin"))
        imageView.center = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        view.addSubview(imageView )
    }


    @IBAction func Tap(_ sender: UIButton) {
        sender.isHidden = true
        
        UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
            switch self.currentAnimation {
                case 0:
                    break
                default:
                    break
            }
        }, completion: { finished in
            sender.isHidden = false
        })
        
        currentAnimation += 1
        
        if currentAnimation > 7 {
            currentAnimation = 0
        }
    }
}

