//
//  GameViewController.swift
//  tilepuzzle
//
//  Created by Kinpira on 2014/11/11.
//  Copyright (c) 2014年 Kinpira. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    var skView : SKView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        skView = self.view as? SKView
        let scene = GameScene(size:self.view.bounds.size)
        skView?.presentScene(scene)
        
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
