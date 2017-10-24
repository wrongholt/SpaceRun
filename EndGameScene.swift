//
//  EndGameScene.swift
//  SpaceRun
//
//  Created by William Rongholt on 5/15/17.
//  Copyright © 2017 assignment 4 William Rongholt. All rights reserved.
//

import Foundation
import SpriteKit



class EndGameScene: SKScene{
    let finalScore = HUDNode().score
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.darkGray
        
        let endLabel = SKLabelNode(fontNamed: "Chalkbuster")
        endLabel.text = "Game Over!"
        endLabel.fontColor = SKColor.red
        endLabel.fontSize = 60
        endLabel.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        self.addChild(endLabel)
        
        let replay = SKSpriteNode(imageNamed: "replay")
        replay.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2 - 100)
        replay.name = "replayButton"
        replay.size = CGSize(width: 100, height: 100)
        replay.zPosition = 1.0;
        self.addChild(replay)
        
        
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let node = atPoint(location )
        if node.name == "replayButton" {
        replaySelected()
        }
        }
    }
    func replaySelected(){
        let replayPushed = GameScene(size: self.size)
        
        replayPushed.scaleMode = self.scaleMode
        let reveal = SKTransition.fade(withDuration: 1)
        self.view?.presentScene(replayPushed, transition: reveal)
    }
    
    
}
