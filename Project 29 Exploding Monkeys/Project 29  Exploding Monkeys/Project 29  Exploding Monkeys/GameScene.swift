//
//  GameScene.swift
//  Project 29  Exploding Monkeys
//
//  Created by Nikita Novikov on 17.11.2022.
//

import SpriteKit

enum CollisionTypes: UInt32 {
    case banana = 1
    case building = 2
    case player = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var buildings: [BuildingNode] = []
    
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var banana: SKSpriteNode!
    
    var endGameLabel: SKLabelNode!
    
    var bananaLaunchTime: Date?
    
    var currentPlayer = 1
    
    weak var viewController: GameViewController?
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
        createBuildings()
        createPlayers()
        createEndgameLabel()
        physicsWorld.contactDelegate = self
        
        let windValue = CGFloat.random(in: -2...2)
        viewController?.updateWindLabel(Int(windValue * 10))
        physicsWorld.gravity = CGVector(dx: windValue, dy: -9.8)
    }
    
    func createEndgameLabel() {
        endGameLabel = SKLabelNode(fontNamed: "Chalkduster")
        endGameLabel.fontSize = frame.height * 0.13
        endGameLabel.zPosition = 100
        endGameLabel.text = "End game"
        endGameLabel.alpha = 0.0
        endGameLabel.fontColor = .black
        endGameLabel.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        endGameLabel.horizontalAlignmentMode = .center
        endGameLabel.verticalAlignmentMode = .center
        addChild(endGameLabel)
    }
    
    func createBuildings() {
        var currentX: CGFloat = -15
         
        while currentX < 1024 {
            let size = CGSize(width: Int.random(in: 2...4) * 40, height: Int.random(in: 300...600))
            currentX += size.width + 2
            
            let building = BuildingNode(color: .red, size: size)
            building.position = CGPoint(x: currentX - (size.width / 2), y: size.height / 2)
            building.setup()
            addChild(building)
            buildings.append(building)
        }
    }
    
    func createPlayers() {
        player1 = SKSpriteNode(imageNamed: "player")
        player1.name = "player1"
        player1.physicsBody = SKPhysicsBody(circleOfRadius: player1.size.width * 0.8)
        player1.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player1.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
        player1.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
        player1.physicsBody?.isDynamic = false
        
        let player1Building = buildings[1]
        player1.position = CGPoint(x: player1Building.position.x, y: player1Building.position.y + (player1Building.size.height + player1.size.height) / 2)
        addChild(player1)
        
        
        player2 = SKSpriteNode(imageNamed: "player")
        player2.name = "player2"
        player2.physicsBody = SKPhysicsBody(circleOfRadius: player2.size.width * 0.8)
        player2.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player2.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
        player2.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
        player2.physicsBody?.isDynamic = false
        
        let player2Building = buildings[buildings.count - 2]
        player2.position = CGPoint(x: player2Building.position.x, y: player2Building.position.y + (player2Building.size.height + player2.size.height) / 2)
        addChild(player2)
    }
    
    func launch(angle: Int, velocity: Int) {
        let speed = Double(velocity) / 10.0
        let radians = deg2rad(degrees: angle)
        
        bananaLaunchTime = .now
        
        if banana != nil {
            banana.removeFromParent()
            banana = nil
        }
        
        banana = SKSpriteNode(imageNamed: "banana")
        banana.name = "banana"
        banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
        banana.physicsBody?.categoryBitMask = CollisionTypes.banana.rawValue
        banana.physicsBody?.collisionBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
        banana.physicsBody?.contactTestBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
        banana.physicsBody?.usesPreciseCollisionDetection = true
        addChild(banana)
        
        if currentPlayer == 1 {
            banana.position = CGPoint(x: player1.position.x - 30, y: player1.position.y + 40)
            banana.physicsBody?.angularVelocity = -20
            
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player1Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
            player1.run(sequence)
            
            let impulse = CGVector(dx: cos(radians) * speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        } else {
            banana.position = CGPoint(x: player2.position.x + 30, y: player2.position.y + 40)
            banana.physicsBody?.angularVelocity = 20
            
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player2Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
            player2.run(sequence)
            
            let impulse = CGVector(dx: cos(radians) * -speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        }
    }
    
    func deg2rad(degrees: Int) -> Double {
        Double(degrees) * .pi / 180.0
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        guard let firstNode = firstBody.node else { return }
        guard let secondNode = secondBody.node else { return }
        
        let bananaFlightTime = bananaLaunchTime?.distance(to: .now)
        
        if firstNode.name == "banana" && secondNode.name == "building" {
            bananaHit(building: secondNode, atPoint: contact.contactPoint)
        }
        
        guard let bananaFlightTime = bananaFlightTime, bananaFlightTime > 0.1 else { return }
        
        if firstNode.name == "banana" && secondNode.name == "player1" {
            destroy(player: player1)
        }
        
        if firstNode.name == "banana" && secondNode.name == "player2" {
            destroy(player: player2)
        }
    }
    
    func destroy(player: SKSpriteNode) {
        if let explosition = SKEmitterNode(fileNamed: "hitPlayer") {
            explosition.position = player.position
            addChild(explosition)
        }
        
        player.removeFromParent()
        banana.removeFromParent()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let newGame = GameScene(size: self.size)
            newGame.viewController = self.viewController
            self.viewController?.currentGame = newGame
            
            let gameIsEnded: Bool
            if player.name == "player1" {
                gameIsEnded = self.viewController?.addScore(to: 2) ?? false
            } else {
                gameIsEnded = self.viewController?.addScore(to: 1) ?? false
            }
            
            self.changePlayer()
            newGame.currentPlayer = self.currentPlayer
            
            if gameIsEnded {
                self.endGame()
            } else {
                let transition = SKTransition.doorway(withDuration: 1.5)
                self.view?.presentScene(newGame, transition: transition)
            }
        }
    }
    
    func endGame() {
        let player1Score = viewController?.player1Score ?? 0
        let player2Score = viewController?.player2Score ?? 0
        let winner = player1Score > player2Score ? 1 : 2
        
        endGameLabel.text = "Player \(winner) win!"
        
        let fadeAlphaAction = SKAction.fadeAlpha(to: 1.0, duration: 1.5)
        endGameLabel.run(fadeAlphaAction)
    }
    
    func changePlayer() {
        if currentPlayer == 1 {
            currentPlayer = 2
        } else {
            currentPlayer = 1
        }
        
        viewController?.activatePlayer(number: currentPlayer)
    }
    
    func bananaHit(building: SKNode, atPoint contactPoint: CGPoint) {
        guard let building = building as? BuildingNode else { return }
        let buildingLocation = convert(contactPoint, to: building)
        building.hit(at: buildingLocation)
        
        if let explosion = SKEmitterNode(fileNamed: "hitBuilding") {
            explosion.position = contactPoint
            addChild(explosion)
        }
        
        banana.name = ""
        banana.removeFromParent()
        banana = nil
        
        changePlayer()
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        guard banana != nil else { return }
        
        if abs(banana.position.y) > 1000 {
            banana.removeFromParent()
            banana = nil
            changePlayer()
        }
    }
}
