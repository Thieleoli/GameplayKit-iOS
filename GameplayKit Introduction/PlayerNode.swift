//
//  PlayerNode.swift
//  GameplayKit Introduction
//
//  Created by Davis Allie on 19/07/2015.
//  Copyright © 2015 Davis Allie. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class PlayerNode: SKShapeNode, GKAgentDelegate {
    
    let player = Player()
    
    
    override init() {
        super.init()
        self.entity = player
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var agent = GKAgent2D()
     
    //  MARK: Agent Delegate
    func agentWillUpdate(_ agent: GKAgent) {
        if let agent2D = agent as? GKAgent2D {
            agent2D.position = float2(Float(position.x), Float(position.y))
            
        }
    }
     
    func agentDidUpdate(_ agent: GKAgent) {
        if let agent2D = agent as? GKAgent2D {
            self.position = CGPoint(x: CGFloat(agent2D.position.x), y: CGFloat(agent2D.position.y))
        }
    }
    
    var enabled = true {
        didSet {
            if self.enabled == false {
                self.alpha = 0.1
                
                self.run(SKAction.customAction(withDuration: 2.0, actionBlock: { (node, elapsedTime) -> Void in
                    if elapsedTime == 2.0 {
                        self.enabled = true
                    }
                }))
                
                self.run(SKAction.fadeIn(withDuration: 2.0))
            }
        }
    }
    
    var stateMachine: GKStateMachine!
     
    @objc func enterNormalState() {
        self.stateMachine.enter(NormalState.self)
    }
    
}

