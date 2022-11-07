//
//  ViewController.swift
//  Project 27 Core Graphics
//
//  Created by Nikita Novikov on 07.11.2022.
//

import UIKit

class SandBoxViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    var currentDrawType = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        drawRectangle()
    }


    @IBAction func redrawButtonTapped(_ sender: UIButton) {
        currentDrawType += 1
        
        if currentDrawType > 5 {
            currentDrawType = 0
        }
        
        switch currentDrawType {
        case 0:
            drawRectangle()
        default:
            break
        }
    }
    
    func drawRectangle() {
        
    }
}

