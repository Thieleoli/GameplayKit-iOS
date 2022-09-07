//
//  RedEnemyNode.swift
//  GameplayKit Introduction
//
//  Created by Davis Allie on 26/07/2015.
//  Copyright © 2015 Davis Allie. All rights reserved.
//

import UIKit

class RedEnemyNode: ContactNode {
    
    override init() {
        super.init()
        self.entity = RedEnemy()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
