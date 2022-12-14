//
//  WhackSlot.swift
//  Project 14 Whack-a-Penguin
//
//  Created by Nikita Novikov on 27.10.2022.
//

import UIKit
import SpriteKit

class WhackSlot: SKNode {
    var charNode: SKSpriteNode!
    
    var isVisible = false
    var isHit = false
    
    func configure(at position: CGPoint) {
        self.position = position
        
        let sprite = SKSpriteNode(imageNamed: "whackHole")
        addChild(sprite)
        
        let cropNode = SKCropNode()
        cropNode.position = CGPoint(x: 0, y: 15)
        cropNode.zPosition = 1
        cropNode.maskNode = SKSpriteNode(imageNamed: "whackMask")
        
        charNode = SKSpriteNode(imageNamed: "penguinGood")
        charNode.position = CGPoint(x: 0, y: -90)
        charNode.name = "character"
        cropNode.addChild(charNode)
        
        addChild(cropNode)
    }
    
    func show(hideTime: Double) {
        if isVisible { return }
        
        charNode.xScale = 1
        charNode.yScale = 1
        
        showMudParticles()
        
        charNode.run(SKAction.moveBy(x: 0, y: 80, duration: hideTime))
        isVisible = true
        isHit = false
        
        if Int.random(in: 0...2) == 0 {
            charNode.texture = SKTexture(imageNamed: "penguinGood")
            charNode.name = "charFriend"
        } else {
            charNode.texture = SKTexture(imageNamed: "penguinEvil")
            charNode.name = "charEnemy"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + hideTime * 3.5) { [weak self] in
            self?.hide()
        }
    }
    
    func hide() {
        if !isVisible { return }
        
        showMudParticles()
        
        charNode.run(SKAction.moveBy(x: 0, y: -80, duration: 0.05))
        isVisible = false
    }
    
    func showMudParticles() {
        if let mudParticles = SKEmitterNode(fileNamed: "MudParticles.sks") {
            let addAction = SKAction.run { self.addChild(mudParticles) }
            let wait = SKAction.wait(forDuration: Double.random(in: 0.4...1.2))
            let removeAction = SKAction.run { mudParticles.removeFromParent() }
            let sequence = SKAction.sequence([addAction, wait, removeAction])
            self.run(sequence)
        }
    }
    
    func hit() {
        isHit = true
        
        if let smokeEffect = SKEmitterNode(fileNamed: "HitSmokeEffect.sks") {
            let addAction = SKAction.run { self.addChild(smokeEffect) }
            let wait = SKAction.wait(forDuration: Double.random(in: 0.9...1.8))
            let removeAction = SKAction.run { smokeEffect.removeFromParent() }
            let sequence = SKAction.sequence([addAction, wait, removeAction])
            self.run(sequence)
        }
        
        let delay = SKAction.wait(forDuration: 0.25)
        let hide = SKAction.moveBy(x: 0, y: -80, duration: 0.5)
        let notVisible = SKAction.run { [weak self] in self?.isVisible = false }
        let sequence = SKAction.sequence([delay, hide, notVisible])
        charNode.run(sequence)
    }
}
