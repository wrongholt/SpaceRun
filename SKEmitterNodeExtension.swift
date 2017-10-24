//
//  SKEmitterNodeExtension.swift
//  SpaceRun
//
//  Created by William Rongholt on 5/10/17.
//  Copyright © 2017 assignment 4 William Rongholt. All rights reserved.
//

import SpriteKit

//.sks files are arcieved in SKemitterNode instances we need to retrieve a copy of that node by loading it form the app bundle. in order to mimic the API that apples uses for sound acitons, we will beuld a Swift extension to add a new method onto the SKemtterNode class
//Note: extions were called in Objective-c

extension String{
    var length: Int{
        return self.characters.count
    }
}
//Now, ;ets extend the skemitterNode class by adding a helper method to it name nodeWithFile()
extension SKEmitterNode{
    class func nodeWithFile(_ fileName: String) -> SKEmitterNode?{
        
        //Break apart the past in file name into a based name and its extension.
        //If the passed in file name has no extension add an extension of .sks
        let baseName = (fileName as NSString).deletingPathExtension
        
        var fileExtension = (fileName as NSString).pathExtension
        
        if fileExtension.length == 0 {
            fileExtension = "sks"
        }
        //grab the main bundle of our app and ask for the path to a resouce using our baseName and fileExtension
        if let path = Bundle.main.path(forResource: baseName, ofType: fileExtension){
            //particle effects in SPriteKit are archived when created so we need to unarchive the effect file .sks so it can be reated as SKEmitterNade object
            
            let node = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! SKEmitterNode
            
            return node
        }
        return nil
        
    }
    
    //we want to add explosions for the two collisions that occur for torpedos vs obsticals and obsticle vs ship
    //We don't want the explosion emitters to keep running indefinitly for this explosions so we will make them die out after a short duration.
    func dieOutInDuration(_ duration: TimeInterval){
        
        //Define two waiting periods because once we set the birthrate to zero
        //we will still need to wait before the existing particles die out.  otherwise the particles will vanish from the screen emediatly.  
        let firstWait = SKAction.wait(forDuration: duration)
        
        //set the birthrate to zero in order to make the particle effect disapear using an SKaction code block
        let stop = SKAction.run{
            [weak self] in
            
            if let weakSelf = self{
                weakSelf.particleBirthRate = 0
            }
        }
        //Set up the sedond wait time
        let secondWait = SKAction.wait(forDuration: TimeInterval(self.particleLifetime))
        let remove = SKAction.removeFromParent()
        run(SKAction.sequence([firstWait, stop, secondWait, remove]))
    }
}
