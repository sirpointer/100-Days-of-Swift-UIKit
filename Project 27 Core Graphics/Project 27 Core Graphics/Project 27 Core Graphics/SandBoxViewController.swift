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
        case 1:
            drawCircle()
        case 2:
            drawCheckerboard()
        default:
            break
        }
    }
    
    func drawRectangle() {
        let side = 512
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: side, height: side))
        
        let image = renderer.image { context in
            let rectangle = CGRect(x: 0, y: 0, width: side, height: side)
            
            context.cgContext.setFillColor(UIColor.red.cgColor)
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.setLineWidth(10)
            
            context.cgContext.addRect(rectangle)
            context.cgContext.drawPath(using: .fillStroke)
        }
        
        imageView.image = image
    }
    
    func drawCircle() {
        let side = 512
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: side, height: side))
        
        let image = renderer.image { context in
            let rectangle = CGRect(x: 0, y: 0, width: side, height: side).insetBy(dx: 5, dy: 5)
            
            context.cgContext.setFillColor(UIColor.red.cgColor)
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.setLineWidth(10)
            
            context.cgContext.addEllipse(in: rectangle)
            context.cgContext.drawPath(using: .fillStroke)
        }
        
        imageView.image = image
    }
    
    func drawCheckerboard() {
        let side = 512
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: side, height: side))
        
        let image = renderer.image { context in
            context.cgContext.setFillColor(UIColor.black.cgColor)
            
            for row in 0..<8 {
                for col in 0..<8 {
                    if (row + col).isMultiple(of: 2) {
                        context.cgContext.fill(CGRect(x: col * 64, y: row * 64, width: 64, height: 64))
                    }
                }
            }
        }
        
        imageView.image = image
    }
}
