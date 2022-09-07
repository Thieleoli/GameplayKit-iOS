//
//  FlashingComponent.swift
//  GameplayKit Introduction
//
//  Created by Thiele Oliveira on 07/09/22.
//  Copyright © 2022 Davis Allie. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class FlashingComponent: GKComponent {

    var nodeToFlash: SKNode!
         
        func startFlashing() {
     
            let fadeAction = SKAction.sequence([SKAction.fadeOut(withDuration: 0.75), SKAction.fadeIn(withDuration: 0.75)])
            nodeToFlash.run(SKAction.repeatForever(fadeAction), withKey: "flash")
             
        }
         
        deinit {
            nodeToFlash.removeAction(forKey: "flash")
        }
}
