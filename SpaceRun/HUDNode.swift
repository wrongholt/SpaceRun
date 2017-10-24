//
//  HUDNode.swift
//  SpaceRun
//
//  Created by William Rongholt on 5/10/17.
//  Copyright © 2017 assignment 4 William Rongholt. All rights reserved.
//

import SpriteKit

class HUDNode: SKNode{
    //create a heads up display that will hold all of our display areas once the node is add to the scene well tell it to lat out its child nodes.
    //The child nodes will not contain labels as we will use the blank nodes as group containers and lay out the label nodes inside of them
    
    //we will left alight the score and right align the lapsed game time
    
    //Build two parent nodes as group containers that will hold score and value labels
    
    //properties
    private let ScoreGroupName = "scoreGroup"
    private let ScoreValueName  = "scoreValue"
    
    private let ElapsedGroupName = "ElapsedGroup"
    private let ElapsedValueName  = "ElapsedValue"
    
    private let TimerActionName = "elapsedGameTimer"
    private let PowerUpGroupName = "powerupGroup"
    private let PowerUpValueName = "powerupValue"
    private let PowerupTimerActionName = "showPowerupTimer"
    private let HealthGroupName = "healthGroup"
    private let HealthValueName = "healthValue"
    
    var elapsedTime: TimeInterval = 0.0
    var score: Int = 0
    
    lazy private var scoreFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    lazy private var timeFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()
    
    override init(){
        super.init()
        
        //Build an empty SKNode and name it so we can get a referance to it later...
        let scoreGroup = SKNode()
        scoreGroup.name = ScoreGroupName
        //create a SKlabelNode for our title
        let scoreTitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        
        scoreTitle.fontSize = 12.0
        scoreTitle.fontColor = SKColor.white
        
        //set verticle and horizontal modes in a way that will help us lay out the labels inside this group node
        scoreTitle.horizontalAlignmentMode = .center
        scoreTitle.verticalAlignmentMode = .bottom
        scoreTitle.text = "SCORE"
        scoreTitle.position = CGPoint(x: 0.0, y: 4.0)
        scoreGroup.addChild(scoreTitle)
        
        
        let scoreValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
        
        scoreValue.fontSize = 20.0
        scoreValue.fontColor = SKColor.white
        
        //set verticle and horizontal modes in a way that will help us lay out the labels inside this group node
        scoreValue.horizontalAlignmentMode = .center
        scoreValue.verticalAlignmentMode = .top
        scoreValue.name = ScoreValueName
        scoreValue.text = "0"
        scoreValue.position = CGPoint(x: 0.0, y: -4.0)
        scoreGroup.addChild(scoreValue)
        
        //add score group as a child of our HUDnode
        addChild(scoreGroup)
        
        //
        ///
        //
        let elapsedGroup = SKNode()
        elapsedGroup.name = ElapsedGroupName
        //create a SKlabelNode for our title
        let elapsedTitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        
        elapsedTitle.fontSize = 12.0
        elapsedTitle.fontColor = SKColor.white
        
        //set verticle and horizontal modes in a way that will help us lay out the labels inside this group node
        elapsedTitle.horizontalAlignmentMode = .center
        elapsedTitle.verticalAlignmentMode = .bottom
        elapsedTitle.text = "TIME"
        elapsedTitle.position = CGPoint(x: 0.0, y: 4.0)
        elapsedGroup.addChild(elapsedTitle)
        
        
        let elapsedValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
        
        elapsedValue.fontSize = 20.0
        elapsedValue.fontColor = SKColor.white
        
        //set verticle and horizontal modes in a way that will help us lay out the labels inside this group node
        elapsedValue.horizontalAlignmentMode = .center
        elapsedValue.verticalAlignmentMode = .top
        elapsedValue.name = ElapsedValueName
        elapsedValue.text = "0.0s"
        elapsedValue.position = CGPoint(x: 0.0, y: -4.0)
        elapsedGroup.addChild(elapsedValue)
        
        //add score group as a child of our HUDnode
        addChild(elapsedGroup)
        
        //
        //
        let powerupGroup = SKNode()
        powerupGroup.name = PowerUpGroupName
        //create a SKlabelNode for our title
        let powerupTitle = SKLabelNode(fontNamed: "AvenirNext-Bold")
        
        powerupTitle.fontSize = 14.0
        powerupTitle.fontColor = SKColor.red
        
        //set verticle and horizontal modes in a way that will help us lay out the labels inside this group node
        powerupTitle.verticalAlignmentMode = .bottom
        powerupTitle.text = "Power-up!"
        powerupTitle.position = CGPoint(x: 0.0, y: 4.0)
        powerupGroup.addChild(powerupTitle)
        
        //setup actions to make our power down timer pulse
        powerupTitle.run(SKAction.repeatForever(SKAction.sequence([SKAction.scale(to: 1.3, duration: 0.03), SKAction.scale(to: 1, duration: 0.3)])))
        
        let powerupValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
        
        powerupValue.fontSize = 20.0
        powerupValue.fontColor = SKColor.red
        
        //set verticle modes in a way that will help us lay out the labels inside this group node
        powerupValue.verticalAlignmentMode = .top
        powerupValue.name = PowerUpValueName
        powerupValue.text = "0.0s left"
        powerupValue.position = CGPoint(x: 0.0, y: -4.0)
        powerupGroup.addChild(powerupValue)
        
        //add score group as a child of our HUDnode
        addChild(powerupGroup)
        
        powerupGroup.alpha = 0.0 // make it invisible at start
        //
      
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //
    //Labels are properly laid out within there parent group nodes but the group nodes are centered on the screen
    //we need to create a layout method that will properly position the groups func 
    func layoutForScene(){
        if let scene = scene{
            
            let sceneSize = scene.size
            
            //the following will be used to calculate positon of each group
            var groupSize = CGSize.zero
            
            if let scoreGroup = childNode(withName: ScoreGroupName){
                
                groupSize = scoreGroup.calculateAccumulatedFrame().size
                
                scoreGroup.position = CGPoint(x: 0.0 - sceneSize.width/2.0 + 40.0, y: sceneSize.height/2.0 - groupSize.height)
                
            }else{
                assert(false, "No score group node was found in the node tree")
                
            }
            
            if let elapsedGroup = childNode(withName: ElapsedGroupName){
                
                groupSize = elapsedGroup.calculateAccumulatedFrame().size
                
                elapsedGroup.position = CGPoint(x: sceneSize.width/2.0 - 30.0, y: sceneSize.height/2.0 - groupSize.height)
                
            }else{
                assert(false, "No score group node was found in the node tree")
                
            }
            
            if let powerupGroup = childNode(withName: PowerUpGroupName){
                
                groupSize = powerupGroup.calculateAccumulatedFrame().size
                
                powerupGroup.position = CGPoint(x: 0.0, y: sceneSize.height/2.0 - groupSize.height)
                
            }else{
                assert(false, "No score group node was found in the node tree")
                
            }
        }
    }

    //show our weapons power up timer countdown
    func showPowerupTimer(_ time: TimeInterval){
        if let powerupGroup = childNode(withName: PowerUpGroupName){
            //Remove any existing action with the following key because we want to restart the tieer as we are claling this method as a result of the player collection a weapons powerup
            powerupGroup.removeAction(forKey: PowerupTimerActionName)
            //look up powervalue
            if let powerValue = powerupGroup.childNode(withName: PowerUpValueName) as! SKLabelNode?{
                //run the countdown swuence
                //
                //the action will repeat itseld every 0.05 seconds in order to update the text in the powerValue label
                //we need to use a weak referance to self to ensure the block does not retain self 
                let start = Date.timeIntervalSinceReferenceDate
                
                let block = SKAction.run {
                    [weak self] in
                    if let weakSelf = self{
                        let elapsedTime = Date.timeIntervalSinceReferenceDate - start
                        let timeLeft = max(time - elapsedTime, 0)
                        
                        let timeLeftFormat = weakSelf.timeFormatter.string(from: NSNumber(value:timeLeft))!
                        
                        powerValue.text = "\(timeLeftFormat)s left"
                    }
                }
                //Actions
                let countDownSequence = SKAction.sequence([block, SKAction.wait(forDuration: 0.05)])
                let countDown = SKAction.repeatForever(countDownSequence)
                let fadeIn = SKAction.fadeAlpha(by: 1.0, duration: 0.1)
                let fadeOut = SKAction.fadeAlpha(by: 0.0, duration: 1.0)
                
                let stopAction = SKAction.run ({ () -> Void in
                    powerupGroup.removeAction(forKey: self.PowerupTimerActionName)
                })
                let visuals = SKAction.sequence([fadeIn, SKAction.wait(forDuration: time), fadeOut, stopAction])
                
                powerupGroup.run(SKAction.group([countDown, visuals]), withKey: self.PowerupTimerActionName)
                
            }
        }
    }
    
    
    func addPoints(_ points: Int) {
        score += points
        //look up our score value in the node tree by name
        if let scoreValue = childNode(withName: "\(ScoreGroupName)/\(ScoreValueName)") as! SKLabelNode?{
            
            //format our score value using the 1000's seperator so lets use our cached self.scoreFormatter
            scoreValue.text = scoreFormatter.string(from: NSNumber(value: score))
            
            //Scale the node up for a breif period of time and scal it back down
            scoreValue.run(SKAction.sequence([SKAction.scale(to: 1.1, duration: 0.02), SKAction.scale(to: 1.1, duration: 0.07)]))
            
        }
    }
    func startGame(){
        
        //calculate the time stamp when starting the game
        let startTime = Date.timeIntervalSinceReferenceDate
        if let elapsedValue = childNode(withName: "\(ElapsedGroupName)/\(ElapsedValueName)") as! SKLabelNode?{
            
            //use a code block to update the elapsed time property to be the differance between the start time and current time stamp
            let update = SKAction.run({
                [weak self] in
                
                if let weakSelf = self{
                    let currentTime = Date.timeIntervalSinceReferenceDate
                    
                    weakSelf.elapsedTime = currentTime - startTime
                    
                    elapsedValue.text = weakSelf.timeFormatter.string(from: NSNumber(value: weakSelf.elapsedTime))
                }
            })
            let updateAndDelay = SKAction.sequence([update, SKAction.wait(forDuration: 0.05)])
            
            let timer =  SKAction.repeatForever(updateAndDelay)
            
            run(timer, withKey: TimerActionName)
            
        }
        
    }
    func endGame(){
        
       //Stop the timer sequence
        removeAction(forKey: TimerActionName)
        
        //if the game ends while a power up  in progress fade the powerup away if not do nothing
        if let powerupGroup = childNode(withName: PowerUpGroupName){
            powerupGroup.removeAction(forKey: PowerupTimerActionName)
            powerupGroup.run(SKAction.fadeAlpha(by: 0.0, duration: 0.3))
        }
        let endScene = EndGameScene(size: (scene?.size)!)
        
        endScene.scaleMode = (scene?.scaleMode)!
        let reveal = SKTransition.fade(withDuration: 3)
        scene?.view?.presentScene(endScene, transition: reveal)
        
    }
}
