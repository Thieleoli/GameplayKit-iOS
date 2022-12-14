//
//  InvulnerableState.swift
//  GameplayKit Introduction
//
//  Created by Thiele Oliveira on 07/09/22.
//  Copyright © 2022 Davis Allie. All rights reserved.
//

import UIKit
import GameplayKit
import SpriteKit

class InvulnerableState: GKState {

    var node: PlayerNode
         
        init(withNode: PlayerNode) {
            node = withNode
        }
         
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
            switch stateClass {
            case is NormalState.Type:
                return true
                 
            default:
                return false
            }
        }
         
    override func didEnter(from previousState: GKState?) {
            if let _ = previousState as? NormalState {
                // Adding Component
                let flash = FlashingComponent()
                flash.nodeToFlash = node
                flash.startFlashing()
                node.entity?.addComponent(flash)
            }
        }
}
