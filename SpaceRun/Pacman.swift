//
//  Pacman.swift
//  SpaceRun
//
//  Created by William Rongholt on 5/11/17.
//  Copyright © 2017 assignment 4 William Rongholt. All rights reserved.
//

import SpriteKit
class Pacman: SKSpriteNode {
    
    init() {
        let pacman1 = SKTexture(imageNamed: "pman1")
        super.init(texture: pacman1, color: .clear, size: (pacman1.size()))
    }
    
    
    func beginAnimation() {
        
        let pmanAtlas = SKTextureAtlas(named: "pman")
        let frames = ["pman1","pman2","pman3","pman4"].map { pmanAtlas.textureNamed($0) }
        let animate = SKAction.animate(with: frames, timePerFrame: 0.1)
        let forever = SKAction.repeatForever(animate)
        self.run(forever)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
