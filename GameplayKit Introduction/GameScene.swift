//
//  GameScene.swift
//  GameplayKit Introduction
//
//  Created by Davis Allie on 19/07/2015.
//  Copyright (c) 2015 Davis Allie. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let worldNode = SKNode()
    let cameraNode = SKCameraNode()
    
    var agents: [GKAgent2D] = []
    var lastUpdateTime: CFTimeInterval = 0.0
    
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
            CGPoint(x: 2048, y: 2400),
            CGPoint(x: 2200, y: 2200)
        ]
    
    var graph: GKObstacleGraph<GKGraphNode2D>!
    
    var initialSpawnDistribution = GKGaussianDistribution(randomSource: GKARC4RandomSource(), lowestValue: 0, highestValue: 2)
    var respawnDistribution = GKShuffledDistribution(randomSource: GKARC4RandomSource(), lowestValue: 0, highestValue: 2)
    
    var ruleSystem = GKRuleSystem()
    
    override func didMove(to view: SKView) {
        
        let obstacles = SKNode.obstacles(fromNodePhysicsBodies: self.children)
        graph = GKObstacleGraph(obstacles: obstacles, bufferRadius: 0.0)
        
        // Adding Component
        let flash = FlashingComponent()
        flash.nodeToFlash = playerNode
        flash.startFlashing()
        playerNode.entity?.addComponent(flash)
                
        playerNode.stateMachine = GKStateMachine(states: [NormalState(withNode: playerNode), InvulnerableState(withNode: playerNode)])
        playerNode.stateMachine.enter(NormalState.self)
        
        /* Scene setup */
        self.addChild(worldNode)
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        self.upDisplayTimer = Timer(timeInterval: 1.0/60.0, target: self, selector: #selector(self.moveUp), userInfo: nil, repeats: true)
        self.rightDisplayTimer = Timer(timeInterval: 1.0/60.0, target: self, selector: #selector(self.moveRight), userInfo: nil, repeats: true)
        self.downDisplayTimer = Timer(timeInterval: 1.0/60.0, target: self, selector: #selector(self.moveDown), userInfo: nil, repeats: true)
        self.leftDisplayTimer = Timer(timeInterval: 1.0/60.0, target: self, selector: #selector(self.moveLeft), userInfo: nil, repeats: true)
        
        self.respawnTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(self.respawn), userInfo: nil, repeats: true)
        RunLoop.main.add(self.respawnTimer, forMode: RunLoop.Mode.common)
        
        self.camera = cameraNode
        self.camera?.position = CGPoint(x: 2048, y: 2048)
        self.camera?.setScale(1.0)
        
        playerNode.position = CGPoint(x: 2048, y: 2048)
        playerNode.fillColor = UIColor.blue
        playerNode.lineWidth = 0.0
        
        playerNode.entity?.addComponent(playerNode.agent)
        playerNode.agent.delegate = playerNode
        
        let playerBody = SKPhysicsBody(circleOfRadius: 50)
        playerBody.contactTestBitMask = 1
        playerNode.physicsBody = playerBody
        
        self.addChild(playerNode)
        self.initialSpawn()
        
        
        let playerDistanceRule = GKRule(blockPredicate: { (system: GKRuleSystem) -> Bool in
            if let value = system.state["spawnPoint"] as? NSValue {
                let point = value.cgPointValue
                 
                let xDistance = abs(point.x - self.playerNode.position.x)
                let yDistance = abs(point.y - self.playerNode.position.y)
                let totalDistance = sqrt((xDistance*xDistance) + (yDistance*yDistance))
                 
                if totalDistance <= 200 {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        }) { (system: GKRuleSystem) -> Void in
            system.assertFact("spawnEnemy" as NSObjectProtocol)
        }
         
        let nodeCountRule = GKRule(blockPredicate: { (system: GKRuleSystem) -> Bool in
            if self.children.count <= 50 {
                return true
            } else {
                return false
            }
        }) { (system: GKRuleSystem) -> Void in
            system.assertFact("shouldSpawn" as NSObjectProtocol, grade: 0.5)
        }
         
        let nodePresentRule = GKRule(blockPredicate: { (system: GKRuleSystem) -> Bool in
            if let value = system.state["spawnPoint"] as? NSValue, self.nodes(at: value.cgPointValue).count == 0 {
                return true
            } else {
                return false
            }
        }) { (system: GKRuleSystem) -> Void in
            let grade = system.grade(forFact: "shouldSpawn" as NSObjectProtocol)
            system.assertFact("shouldSpawn" as NSObjectProtocol, grade: (grade + 0.5))
        }
         
        self.ruleSystem.add([playerDistanceRule, nodeCountRule, nodePresentRule])
        
        
    }
   
    override func update(_ currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        self.camera?.position = playerNode.position
        
        if self.lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        let delta = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        playerNode.agent.update(deltaTime: delta)
        
        for agent in agents {
            agent.update(deltaTime: delta)
        }
    }
    
    //  MARK: Respawning Behaviour
    func initialSpawn() {
        
        let endNode = GKGraphNode2D(point: float2(x: 2048.0, y: 2048.0))
        self.graph.connectUsingObstacles(node: endNode)
        
        for point in self.spawnPoints {
//            let respawnFactor = arc4random() % 3  //  Will produce a value between 0 and 2 (inclusive)
            let respawnFactor = self.initialSpawnDistribution.nextInt()
            
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
            
            print(node?.entity)
            if let entity = node?.value(forKey: "entity") as? GKEntity,
               let agent = node?.value(forKey: "agent") as? GKAgent2D, respawnFactor != 0 {

                entity.addComponent(agent)
                agent.delegate = node as? ContactNode
                agent.position = float2(x: Float(point.x), y: Float(point.y))
                agents.append(agent)

                /*let behavior = GKBehavior(goal: GKGoal(toSeekAgent: playerNode.agent), weight: 1.0)
                agent.behavior = behavior*/

                /* BEGIN PATHFINDING  */
                let startNode = GKGraphNode2D(point: agent.position)
                self.graph.connectUsingObstacles(node: startNode)

                let pathNodes = self.graph.findPath(from: startNode, to: endNode) as! [GKGraphNode2D]

                if !pathNodes.isEmpty {
                    let path = GKPath(graphNodes: pathNodes, radius: 1.0)

                    let followPath = GKGoal(toFollow: path, maxPredictionTime: 1.0, forward: true)
                    let stayOnPath = GKGoal(toStayOn: path, maxPredictionTime: 1.0)

                    let behavior = GKBehavior(goals: [followPath, stayOnPath])
                    agent.behavior = behavior
                }

                self.graph.remove([startNode])
                /* END PATHFINDING */

                agent.mass = 0.01
                agent.maxSpeed = 50
                agent.maxAcceleration = 1000
            }

            node!.position = point
            node!.strokeColor = UIColor.clear
            node!.physicsBody!.contactTestBitMask = 1
            self.addChild(node!)
        }

        self.graph.remove([endNode])
        
    }
        
    
    @objc func respawn() {
        let endNode = GKGraphNode2D(point: float2(x: 2048.0, y: 2048.0))
        self.graph.connectUsingObstacles(node: endNode)
             
            for point in self.spawnPoints {
                self.ruleSystem.reset()
                self.ruleSystem.state["spawnPoint"] = NSValue(cgPoint: point)
                self.ruleSystem.evaluate()
                 
                if self.ruleSystem.grade(forFact: "shouldSpawn" as NSObjectProtocol) == 1.0 {
                    var respawnFactor = self.respawnDistribution.nextInt()
                     
                    if self.ruleSystem.grade(forFact: "spawnEnemy" as NSObjectProtocol) == 1.0 {
                        respawnFactor = self.initialSpawnDistribution.nextInt()
                    }
                     
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
                     
                    if let entity = node?.value(forKey: "entity") as? GKEntity,
                       let agent = node?.value(forKey: "agent") as? GKAgent2D, respawnFactor != 0 {
                             
                        entity.addComponent(agent)
                        agent.delegate = node as? ContactNode
                        agent.position = float2(x: Float(point.x), y: Float(point.y))
                        agents.append(agent)
                         
                        let startNode = GKGraphNode2D(point: agent.position)
                        self.graph.connectUsingObstacles(node: startNode)
                         
                        let pathNodes = self.graph.findPath(from: startNode, to: endNode) as! [GKGraphNode2D]
                         
                        if !pathNodes.isEmpty {
                            let path = GKPath(graphNodes: pathNodes, radius: 1.0)
                             
                            let followPath = GKGoal(toFollow: path, maxPredictionTime: 1.0, forward: true)
                            let stayOnPath = GKGoal(toStayOn: path, maxPredictionTime: 1.0)
                             
                            let behavior = GKBehavior(goals: [followPath, stayOnPath])
                            agent.behavior = behavior
                        }
                         
                        self.graph.remove([startNode])
                         
                        agent.mass = 0.01
                        agent.maxSpeed = 50
                        agent.maxAcceleration = 1000
                    }
                     
                    node!.position = point
                    node!.strokeColor = UIColor.clear
                    node!.physicsBody!.contactTestBitMask = 1
                    self.addChild(node!)
                }
            }
             
        self.graph.remove([endNode])
    }
    
    //  MARK: Movement Methods
    func startMoveUp() {
        RunLoop.main.add(self.upDisplayTimer, forMode: RunLoop.Mode.common)
    }
    
    func endMoveUp() {
        self.upDisplayTimer.invalidate()
        self.upDisplayTimer = Timer(timeInterval: 1.0/60.0, target: self, selector: #selector(moveUp), userInfo: nil, repeats: true)
    }
    
    @objc func moveUp() { //movimentar para cima
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
        self.rightDisplayTimer = Timer(timeInterval: 1.0/60.0, target: self, selector: #selector(moveRight), userInfo: nil, repeats: true)
    }
    
    @objc func moveRight() { //movimentar para direita
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
        self.downDisplayTimer = Timer(timeInterval: 1.0/60.0, target: self, selector: #selector(moveDown), userInfo: nil, repeats: true)
    }
    
    @objc func moveDown() { //movimentar para baixo
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
        self.leftDisplayTimer = Timer(timeInterval: 1.0/60.0, target: self, selector: #selector(moveLeft), userInfo: nil, repeats: true)
    }
    
    @objc func moveLeft() {  //movimentar para esquerda
        let action = SKAction.moveBy(x: -10, y: 0, duration: 1.0/60.0)
        if self.playerNode.enabled {
            self.playerNode.run(action)
        }
    }
}

extension GameScene: SKPhysicsContactDelegate{
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
        else if contact is RedEnemyNode && playerNode.stateMachine.currentState! is NormalState {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateScore") , object: self, userInfo: ["score": -2])
            
            playerNode.stateMachine.enter(InvulnerableState.self)
            playerNode.perform(Selector(("enterNormalState")), with: nil, afterDelay: 5.0)
        }
        else if contact is YellowEnemyNode  && playerNode.stateMachine.currentState! is NormalState  {
            self.playerNode.enabled = false
        }
        
        contact.removeFromParent()
    }

}
