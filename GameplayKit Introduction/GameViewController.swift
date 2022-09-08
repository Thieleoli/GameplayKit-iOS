//
//  GameViewController.swift
//  GameplayKit Introduction
//
//  Created by Davis Allie on 19/07/2015.
//  Copyright (c) 2015 Davis Allie. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    var mainScene: GameScene!

    @IBOutlet weak var scoreLabel: UILabel!
    var score = 0 {
        didSet {
            self.scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene(fileNamed:"GameScene") {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .resizeFill
            
            skView.presentScene(scene)
            mainScene = scene
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateScore(notification:)), name: NSNotification.Name(rawValue: "updateScore"), object: nil)
    }

    @objc func updateScore(notification: NSNotification) {
        let scoreToAdd = notification.userInfo?["score"] as! Int
        self.score += scoreToAdd
    }
    



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }


    // MARK: Button Movements
    @IBAction func beginMovement(_ sender: Any) {
        switch (sender as AnyObject).tag {
        case 1:
            self.mainScene.startMoveUp()
        case 2:
            self.mainScene.startMoveRight()
        case 3:
            self.mainScene.startMoveDown()
        case 4:
            self.mainScene.startMoveLeft()
        default:
            break
        }
    }

    @IBAction func endMovement(_ sender: Any) {
        switch (sender as AnyObject).tag {
        case 1:
            self.mainScene.endMoveUp()
        case 2:
            self.mainScene.endMoveRight()
        case 3:
            self.mainScene.endMoveDown()
        case 4:
            self.mainScene.endMoveLeft()
        default:
            break
        }
    }
    
}
