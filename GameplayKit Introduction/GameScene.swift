//
//  GameScene.swift
//  GameplayKit Introduction
//
//  Created by Davis Allie on 19/07/2015.
//  Copyright (c) 2015 Davis Allie. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let worldNode = SKNode()
    let cameraNode = SKCameraNode()
    
    let playerNode = PlayerNode(circleOfRadius: 50)
    
    var upDisplayTimer: Timer!
    var rightDisplayTimer: Timer!
    var downDisplayTimer: Timer!
    var leftDisplayTimer: Timer!
    
    var respawnTimer: Timer!
    
    let spawnPoints = [
        CGPoint(x: 245, y: 3900),
        CGPoint(x: 700, y: 3500),
        CGPoint(x: 1250, y: 1500),
        CGPoint(x: 1200, y: 1950),
        CGPoint(x: 1200, y: 2450),
        CGPoint(x: 1200, y: 2950),
        CGPoint(x: 1200, y: 3400),
        CGPoint(x: 2550, y: 2350),
        CGPoint(x: 2500, y: 3100),
        CGPoint(x: 3000, y: 2400),
    ]
    
    override func didMove(to view: SKView) {
        
        
        // Adding Componentt
        let flash = FlashingComponent()
        flash.nodeToFlash = playerNode
        flash.startFlashing()
        playerNode.entity?.addComponent(flash)
//        teste
        
        /* Scene setup */
        self.addChild(worldNode)
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        self.upDisplayTimer = Timer(timeInterval: 1.0/60.0, target: self, selector: #selector(self.moveUp), userInfo: nil, repeats: true)
        self.rightDisplayTimer = Timer(timeInterval: 1.0/60.0, target: self, selector: #selector(self.moveRight), userInfo: nil, repeats: true)
        self.downDisplayTimer = Timer(timeInterval: 1.0/60.0, target: self, selector: #selector(self.moveDown), userInfo: nil, repeats: true)
        self.leftDisplayTimer = Timer(timeInterval: 1.0/60.0, target: self, selector: #selector(moveLeft), userInfo: nil, repeats: true)
        
        self.respawnTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(self.respawn), userInfo: nil, repeats: true)
        RunLoop.main.add(self.respawnTimer, forMode: RunLoop.Mode.common)
        
        self.camera = cameraNode
        self.camera?.position = CGPoint(x: 2048, y: 2048)
        self.camera?.setScale(1.0)
        
        playerNode.position = CGPoint(x: 2048, y: 2048)
        playerNode.fillColor = UIColor.blue
        playerNode.lineWidth = 0.0
        
        let playerBody = SKPhysicsBody(circleOfRadius: 50)
        playerBody.contactTestBitMask = 1
        playerNode.physicsBody = playerBody
        
        self.addChild(playerNode)
        self.initialSpawn()
    }
   
    override func update(_ currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        self.camera?.position = playerNode.position
    }
    
    //  MARK: Physics Delegate
    func didBeginContact(contact: SKPhysicsContact) {
        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node
        
        if let contact = nodeA as? ContactNode, nodeB! is PlayerNode {
            self.handleContactWithNode(contact: contact)
        }
        else if let contact = nodeB as? ContactNode, nodeA! is PlayerNode {
            self.handleContactWithNode(contact: contact)
        }
    }
    
    func handleContactWithNode(contact: ContactNode) {
        if contact is PointsNode {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateScore") , object: self, userInfo: ["score": 1])
        }
        else if contact is RedEnemyNode {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateScore") , object: self, userInfo: ["score": -2])
        }
        else if contact is YellowEnemyNode {
            self.playerNode.enabled = false
        }
        
        contact.removeFromParent()
    }
    
    //  MARK: Respawning Behaviour
    func initialSpawn() {
        for point in self.spawnPoints {
            let respawnFactor = arc4random() % 3  //  Will produce a value between 0 and 2 (inclusive)
            
            var node: SKShapeNode? = nil
            
            switch respawnFactor {
            case 0:
                node = PointsNode(circleOfRadius: 25)
                node!.physicsBody = SKPhysicsBody(circleOfRadius: 25)
                node!.fillColor = UIColor.green
            case 1:
                node = RedEnemyNode(circleOfRadius: 75)
                node!.physicsBody = SKPhysicsBody(circleOfRadius: 75)
                node!.fillColor = UIColor.red
            case 2:
                node = YellowEnemyNode(circleOfRadius: 50)
                node!.physicsBody = SKPhysicsBody(circleOfRadius: 50)
                node!.fillColor = UIColor.yellow
            default:
                break
            }
            
            node!.position = point
            node!.strokeColor = UIColor.clear
            node!.physicsBody!.contactTestBitMask = 1
            self.addChild(node!)
        }
    }
    
    @objc func respawn() {
        
    }
    
    //  MARK: Movement Methods
    func startMoveUp() {
        RunLoop.main.add(self.upDisplayTimer, forMode: RunLoop.Mode.common)
    }
    
    func endMoveUp() {
        self.upDisplayTimer.invalidate()
        self.upDisplayTimer = Timer(timeInterval: 1.0/60.0, target: self, selector: #selector(self.moveUp), userInfo: nil, repeats: true)
    }
    
    @objc func moveUp() {
        let action = SKAction.moveBy(x: 0, y: 10, duration: 0.0)
        if self.playerNode.enabled {
            self.playerNode.run(action)
        }
    }
    
    func startMoveRight() {
        RunLoop.main.add(self.rightDisplayTimer, forMode: RunLoop.Mode.common)
    }
    
    func endMoveRight() {
        self.rightDisplayTimer.invalidate()
        self.rightDisplayTimer = Timer(timeInterval: 1.0/60.0, target: self, selector: #selector(self.moveRight), userInfo: nil, repeats: true)
    }
    
    @objc func moveRight() {
        let action = SKAction.moveBy(x: 10, y: 0, duration: 0.0)
        if self.playerNode.enabled {
            self.playerNode.run(action)
        }
    }
    
    func startMoveDown() {
        RunLoop.main.add(self.downDisplayTimer, forMode: RunLoop.Mode.common)
    }
    
    func endMoveDown() {
        self.downDisplayTimer.invalidate()
        self.downDisplayTimer = Timer(timeInterval: 1.0/60.0, target: self, selector: #selector(self.moveDown), userInfo: nil, repeats: true)
    }
    
    @objc func moveDown() {
        let action = SKAction.moveBy(x: 0, y: -10, duration: 1.0/60.0)
        if self.playerNode.enabled {
            self.playerNode.run(action)
        }
    }
    
    func startMoveLeft() {
        RunLoop.main.add(self.leftDisplayTimer, forMode: RunLoop.Mode.common)
    }
    
    func endMoveLeft() {
        self.leftDisplayTimer.invalidate()
        self.leftDisplayTimer = Timer(timeInterval: 1.0/60.0, target: self, selector: #selector(self.moveLeft), userInfo: nil, repeats: true)
    }
    
    @objc func moveLeft() {
        let action = SKAction.moveBy(x: -10, y: 0, duration: 1.0/60.0)
        if self.playerNode.enabled {
            self.playerNode.run(action)
        }
    }
}
