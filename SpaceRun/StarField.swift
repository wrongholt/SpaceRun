//
//  StarField.swift
//  SpaceRun
//
//  Created by William Rongholt on 5/10/17.
//  Copyright © 2017 assignment 4 William Rongholt. All rights reserved.
//

import Foundation
import SpriteKit

class StarField: SKNode {
    
    
    override init(){
        super.init()
        initSetup()
    }
    required init?(coder aDecoder: NSCoder){
        super.init()
        initSetup()
    }
    
    
    func initSetup(){
        //Because we need to call a method on self(launchStar) from inside a code block we mus create a weak referance to self.  
        //This is what we are doing with [weak self] and then eventually assigning the "weak" self to a constant called weakSelf
        //The run action holds a strong referance to the code block and the node(self) holds a strong referance to the run action. If the code block held a strong referance to the node, then the run action, the code block and the node would all hold strong referance to each other foming a retain cycle which would never get deallocated => memory leak.
        let update = SKAction.run{
            [weak self] in
            
            if arc4random_uniform(10) < 5{
                if let weakSelf = self{
                    weakSelf.launchStar()
                }
            }
        }
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 0.01), update])))
    }
    
    func launchStar(){
       //make sure we have a referance to our scene
        if let scene = self.scene{
            //calculate a random starting point at the top of the screen
            let randomX = Double(arc4random_uniform(uint(scene.size.width)))
            
            let maxY = Double(scene.size.height)
            
            let randomStart = CGPoint(x: randomX, y:maxY)
            
            let star = SKSpriteNode(imageNamed: "shootingStar")
            
            star.position = randomStart
            
            star.alpha = 0.1 + (CGFloat(arc4random_uniform(10)) / 10.0)
            
            star.size = CGSize(width: 3.0 - star.alpha, height: 8.0 - star.alpha)
            //stack the stars from dimmest to brightest in the z axis
            star.zPosition = -100 + star.alpha * 10
            //move the star toward the bottom of the screen using a random duration removing the star when it passes the bottom edge.
            //The differant speeds of the stars based on the duration will give the elution of a paralax effect
            let destY = 0.0 - scene.size.height - star.size.height
            let duration = Double(-star.alpha + 1.8)
            addChild(star)
            star.run(SKAction.sequence([SKAction.moveBy(x: 0.0, y: destY, duration: duration), SKAction.removeFromParent()]))
        }
    }
    
    
    
}
