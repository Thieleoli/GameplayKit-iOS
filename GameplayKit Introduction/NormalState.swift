//
//  NormalState.swift
//  GameplayKit Introduction
//
//  Created by Thiele Oliveira on 07/09/22.
//  Copyright © 2022 Davis Allie. All rights reserved.
//

import UIKit
import GameplayKit
import SpriteKit

class NormalState: GKState {

    var node: PlayerNode
         
        init(withNode: PlayerNode) {
            node = withNode
        }
         
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
            switch stateClass {
            case is InvulnerableState.Type:
                return true
                 
            default:
                return false
            }
        }
         
    override func didEnter(from previousState: GKState?) {
            if let _ = previousState as? InvulnerableState {
                node.entity?.removeComponent(ofType: FlashingComponent.self)
                node.run(SKAction.fadeIn(withDuration: 0.5))
            }
        }
    
}
