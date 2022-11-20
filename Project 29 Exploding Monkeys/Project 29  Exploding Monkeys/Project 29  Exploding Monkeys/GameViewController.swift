//
//  GameViewController.swift
//  Project 29  Exploding Monkeys
//
//  Created by Nikita Novikov on 17.11.2022.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, ObservableObject {
    
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var playerNumber: UILabel!
    @IBOutlet var launchButton: UIButton!
    @IBOutlet var velocityLabel: UILabel!
    @IBOutlet var angleLabel: UILabel!
    @IBOutlet var velocitySlider: UISlider!
    @IBOutlet var angleSlider: UISlider!
    
    var currentGame: GameScene?
    
    private(set) var player1Score = 0
    private(set) var player2Score = 0
    
    
    /// Add 1 score to player.
    /// - Returns: Game is ended.
    func addScore(to playerNumber: Int) -> Bool {
        if playerNumber == 1 {
            player1Score += 1
        } else {
            player2Score += 1
        }
        
        updateScoreLabel()
        
        return player2Score >= 3 || player1Score >= 3
    }
    
    func updateScoreLabel() {
        scoreLabel.text = "Score \(player1Score):\(player2Score)"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                currentGame = scene as? GameScene
                currentGame?.viewController = self
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        player1Score = 0
        player2Score = 0
        updateScoreLabel()
        angleChanged(angleSlider)
        velocityChanged(velocitySlider)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func angleChanged(_ sender: UISlider) {
        angleLabel.text = "Angle: \(Int(angleSlider.value))°"
    }
    
    @IBAction func velocityChanged(_ sender: UISlider) {
        velocityLabel.text = "Velocity: \(Int(velocitySlider.value))"
    }
    
    @IBAction func launch(_ sender: UIButton) {
        angleSlider.isHidden = true
        angleLabel.isHidden = true
        
        velocityLabel.isHidden = true
        velocitySlider.isHidden = true
        
        launchButton.isHidden = true
        
        currentGame?.launch(angle: Int(angleSlider.value), velocity: Int(velocitySlider.value))
    }
    
    func activatePlayer(number: Int) {
        if number == 1 {
            playerNumber.text = "<<< PLAYER ONE"
        } else {
            playerNumber.text = "PLAY ER TWO >>>"
        }
        
        angleSlider.isHidden = false
        angleLabel.isHidden = false
        
        velocityLabel.isHidden = false
        velocitySlider.isHidden = false
        
        launchButton.isHidden = false
    }
}
