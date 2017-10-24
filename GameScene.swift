//
//  GameScene.swift
//  SpaceRun
//
//  Created by William Rongholt on 5/1/17.
//  Copyright © 2017 assignment 4 William Rongholt. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    //class properties
    
    
    //instance properties
    private let SpaceshipNodeName = "ship"
    private let PhotonTorpedoNodeName = "photon"
    private let ObstacleNodeName = "obstacle"
    private let PowerupNodeName = "powerup"
    private let ShipPowerupNodeName = "shippowerup"
    private let HealthPowerupNodeName = "shipHealth"
    private let PacmanNodeName = "pacman"
    private let HUDNodeName = "hud"
    
    //properties to hold sound actions.  We will be preloading our sound files into these variables
    private let shootSound: SKAction = SKAction.playSoundFileNamed("laserShot.wav", waitForCompletion: false)
    private let obsticleExplodeSound: SKAction = SKAction.playSoundFileNamed("darkExplosion.wav", waitForCompletion: false)
    private let shipExplodeSound: SKAction = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    
    
    private weak var shipTouch: UITouch?
    private var lastUpdateTime: TimeInterval = 0
    private var lastShotFireTime: TimeInterval = 0
    private let defaultFireRate: Double = 0.5
    private var shipFireRate: Double = 0.5
    private let powerUpDuration: TimeInterval = 5.0
    private var shipHealthRate: Int = 2
    private var pmanHealth: Int = 2
    
    //we will be using the explosion particle emitters over and over. We don't wnat to load them from there sks files so instead we will create properties and load them for quick reuse like we did for our sound properties.
    private let shipExplodeTemplate: SKEmitterNode = SKEmitterNode.nodeWithFile("shipExplode.sks")!
    private let obsticleExplodeTemplate: SKEmitterNode = SKEmitterNode.nodeWithFile("obsticleExplode.sks")!
    private let shield = SKEmitterNode.nodeWithFile("shield.sks")!
    private let shield2 = SKEmitterNode.nodeWithFile("shield2.sks")!
    
    
    
    private let shipUpgraded = SKSpriteNode(imageNamed: "SpaceshipUp")
    private let ship = SKSpriteNode(imageNamed: "Spaceship.png")
    //Define an initializer method for this class
    override init(size: CGSize) {
        super.init(size: size)
        
        setupGame(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupGame(size: CGSize){

        
        self.ship.position = CGPoint(x: size.width/2.0, y: size.height/2.0)
        self.ship.size = CGSize(width: 40.0, height: 40.0)
        self.ship.name = SpaceshipNodeName
        
        addChild(self.ship) //add this node to the scen's scene graph node tree
        //add ship thruster effect as a child of our ship
        
        ship.addChild(shield2)
        
        self.shield.position = CGPoint(x: 0.0, y: 0.0)
        
        self.shield2.position = CGPoint(x: 0.0, y: 0.0)
        
        
        if let thruster = SKEmitterNode.nodeWithFile("thruster.sks"){
            thruster.position = CGPoint(x: 0.0, y: -20.0)
            //now add thruster to ship
            self.ship.addChild(thruster)
            
        }
        //set up our hud
        let hudNode = HUDNode() //instanciate the HUDNode class
        hudNode.name = HUDNodeName
        //by default nodes will overlap according to the order in which they were aded to the scene if we wish to alter the stacking order we can use a nodes zposition to do so
        hudNode.zPosition = 100.0
        //set the position of the HUD node to bbe at the center of the screen
        //all the child nodes we add to ut will be positioned relative to the HUD nodes origin point
        hudNode.position = CGPoint(x: size.width/2.0, y: size.height/2.0)
        addChild(hudNode)
        
        //llayout the score and time labels
        hudNode.layoutForScene()
        
        //Start the game already...
        hudNode.startGame()
        
        //add our star field paralax effect to the scene by creating an instance of our starField Class
        addChild(StarField())
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //grab any touches noting that touches is a Set(collection) of UITouch objects
        if let touch = touches.first{
            //            //locate the touch point in the scene
            //            let touchPoint = touch.location(in: self)
            //            //We need to reacquire a referance to our ship node from the scene graph node tree
            //            if let ship = self.childNode(withName: SpaceshipNodeName){
            //                //reposition the ship to the touch point
            //                ship.position = touchPoint
            self.shipTouch = touch
            
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        //if this is the first frame rendered for this scene..
        if lastUpdateTime == 0{
            lastUpdateTime = currentTime
        }
        
        //Calclulate the time change(delta time) since the last frame
        let timeDelta = currentTime - lastUpdateTime
        
        // if the touch is still there (since ship touch is a weak referance it will automatically be set to nil
        //by the touch-handling system when it releases touches after they are done), find the ship in the Scene Graph by its name and update ties position property to the poijt that was touched on the screen.
        //This happens every frame because we are inside update() so the ship should keep up with wherever the users finguer moves on the screen
        
        if let shipTouch = self.shipTouch {
            //            if let ship = self.childNode(withName: SpaceshipNodeName){
            //                //reposition the ship again
            //                ship.position = shipTouch.location(in: self)
            //            }
            //call a method to reposition the ship which will move the ship a little ways along the path toward touch point.
            moveShipTowardPoint(touchPoint: shipTouch.location(in: self), timeDelta: timeDelta)
            //we want photon torpedos to lainch from our ship when the users finers is in contact with the screen and if the differance between the current time and the last time a torpedo was fired is greater than a hald second
            if currentTime - lastShotFireTime > shipFireRate {
                
                shoot() //fire a photon torpedo
                
                lastShotFireTime = currentTime
            }
        }
        
       
        //we want to release obstiles some percentage of the time a frame is drawn
        
        if arc4random_uniform(1000) <= 15{
            dropThing()
            //dropAstroid()
        }
        
        
        //check for collisions between our sprites
        checkCollisions()
        
        //update lastUpdate to current time
        lastUpdateTime = currentTime
        
    }
    //
    //Nudge the ship toward the touch point by an apporpiate distance based on a elapsed time since our last fram
    func moveShipTowardPoint(touchPoint: CGPoint, timeDelta: TimeInterval){
        
        //set up the speed points per second the ship should travel
        let shipSpeed = CGFloat(300)
        
        if let ship = self.childNode(withName: SpaceshipNodeName){
            //using the pythagorean therum determine the ships current position and the touch point
            let distanceLetToTravel = sqrt(pow(ship.position.x - touchPoint.x, 2) + pow(ship.position.y - touchPoint.y, 2))
            
            //if the distance left to travel is greater than 6 points, thankeep moving the ship otherwise stop moving the ship because we may experiance "jitter" around the touchpoint due to imprecition with floats.
            if distanceLetToTravel > 6{
                //calculate how far we should move the ship during this frame
                let deltaDistance = CGFloat(timeDelta) * shipSpeed
                
                //convert the distance remaining to move back into (x,y) coordinates using the atan2() function to determine the proper angle based on ships position and destination
                let angle = atan2(touchPoint.y - ship.position.y, touchPoint.x - ship.position.x)
                //Then, using the angle along with the trig sine and cosine functions, determine the x and y offsets
                let xOffset = deltaDistance * cos(angle)
                let yOffset = deltaDistance * sin(angle)
                
                //Use the offsets to reposition the ship
                ship.position = CGPoint(x: ship.position.x + xOffset, y: ship.position.y + yOffset)
                
            }
            
        }
        
        
    }
    
    
    func shoot() {
        
        if let ship = self.childNode(withName: SpaceshipNodeName){
            //create a photon torpedo sprite
            if ship == shipUpgraded{
                let missle = SKSpriteNode(imageNamed: "missle")
                missle.name = PhotonTorpedoNodeName
                missle.position = ship.position
                missle.size = CGSize(width: 60.0, height: 60.0)
                
                self.addChild(missle)
                
                let flyAction = SKAction.moveBy(x: 0, y: self.size.height + missle.size.height, duration: 0.5)
                
                let remove = SKAction.removeFromParent()
                
                let fireAndRemove = SKAction.sequence([flyAction, remove])
                
                missle.run(fireAndRemove)
                
                self.run(self.shootSound)
            }else{
                let photon = SKSpriteNode(imageNamed: "photon")
                photon.name = PhotonTorpedoNodeName
                photon.position = ship.position
                
                self.addChild(photon)
                
                
                //move the torpedo from its original position past the top edge of the screen over hald a scdond.
                //Note: the y-axis in sprite kit is flipped back to normal
                //0,0 bottom left corner and scene hieght self.size.hieght is the top edge of the screen
                let flyAction = SKAction.moveBy(x: 0, y: self.size.height + photon.size.height, duration: 0.5)
                
                //Run the action
                //photon.run(flyAction)
                //remove the torpedo once it leaves the scene
                let remove = SKAction.removeFromParent()
                
                let fireAndRemove = SKAction.sequence([flyAction, remove])
                
                photon.run(fireAndRemove)
                
                self.run(self.shootSound)
            }
        }
        
    }
    
    
    //drop obsticles, power ups, ships
    func dropThing(){
        let dieRoll = arc4random_uniform(100) //die value 0-99
        if dieRoll < 10{
            dropHealthPowerUp()
        }else if dieRoll < 18{
            dropShipPowerUp()
        }else if dieRoll < 25{
            dropWeaponsPowerUp()
        }else if dieRoll < 40 {
            dropEnemyShip()
        }else if dieRoll > 95 {
            dropPacman()
        }else{
            dropAstroid()
        }
    }
    //function that drops astroids randomly from random points above the top edge of the screen they should travel downward at random angles and speeds until they drop bottom, side or get destroy and then get removed
    func dropAstroid(){
        
        //Define astroid size which should be a random number between 15 and 44 points
        let sideSize = Double(arc4random_uniform(30) + 15)
        
        //Maximum x value for the scene
        let maxX = Double(self.size.width)
        let quarterX = maxX / 4.0
        let randRange = UInt32(maxX + (quarterX * 2))
        //arc4Random_uniform requires a Uint32 parameter
        //Determine the staring x-position for the astroid
        let startX = Double(arc4random_uniform(randRange)) - quarterX
        
        //starting y position above the screen
        let startY = Double(self.size.height) + sideSize
        
        //Radom x position
        let endX = Double(arc4random_uniform(UInt32(maxX)))
        
        //ensure they end below the end of the bottom screen
        let endY = 0.0 - sideSize
        
        //create our astroid sprite and set its properties
        
        let astroid = SKSpriteNode(imageNamed: "asteroid")
        astroid.size = CGSize(width: sideSize, height: sideSize)
        astroid.position = CGPoint(x: startX, y: startY)
        
        astroid.name = ObstacleNodeName
        
        self.addChild(astroid)
        
        //run some acitons to get our astroid moving
        //move out astroid to a randomly generated point over a duration of 3-6 seconds
        let move = SKAction.move(to: CGPoint(x: endX, y:endY), duration: Double(arc4random_uniform(4) + 3))
        
        let remove = SKAction.removeFromParent()
        
        let travelAndRemove = SKAction.sequence([move, remove])
        
        //As the astroid is moving rotate it by 3 radians(just under 180 degrees) over 1-3 seconds
        let spin = SKAction.rotate(byAngle: 3, duration: Double(arc4random_uniform(3) + 1))
        
        let spinForever = SKAction.repeatForever(spin)
        
        let groupActions = SKAction.group([spinForever, travelAndRemove])
        
        astroid.run(groupActions)
        
    }
    func dropPacman(){
        
        let sideSize = Double(arc4random_uniform(30) + 15)
        let maxX = Double(self.size.width)
        let startX = Double(maxX / 2)
        let startY = Double(self.size.height) + sideSize
        
        let endX = Double(arc4random_uniform(UInt32(maxX)))
        
        let endY = 0.0 - sideSize
        
        let pman = Pacman()
        pman.position = CGPoint(x: startX, y: startY)
        pman.size = CGSize(width: 100, height: 100)
        pman.name = PacmanNodeName
        
        self.addChild(pman)
        
        let move = SKAction.move(to: CGPoint(x: endX, y:endY), duration: 6)
        
        let remove = SKAction.removeFromParent()
        
        let travelAndRemove = SKAction.sequence([move, remove])
        
        pman.run(travelAndRemove)
        
        pman.beginAnimation()
        
    }
    func dropEnemyShip(){
        let sideSize = 30.0
        
        //Determine the staring x-position for the enemy ship
        let startX = Double(arc4random_uniform(uint(self.size.width - 40)) + 20)
        
        //starting y position above the screen
        let startY = Double(self.size.height) + sideSize
        
        //create our astroid sprite and set its properties
        
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.size = CGSize(width: sideSize, height: sideSize)
        enemy.position = CGPoint(x: startX, y: startY)
        
        enemy.name = ObstacleNodeName
        
        self.addChild(enemy)
        
        //set up enemy ship movement
        //we want the enemy ship to follow a cureved flight path(bezier curve) which uses control ponts to define how the curature  of the path is formed. the following method call will return the path the eenmey
        let shipPath = createBezier()
        
        //use the shipPath to moview our ebemy ship
        //asOffset is set to true lets us treat the actual point values as offsets from the enmey ships starting point
        //if False the paths points would be treated as absolute positions on the screen
        //
        //OrenttoPath if true the enemy ship turns and moves the directions of the path automatically
        let followPath = SKAction.follow(shipPath, asOffset: true, orientToPath: true, duration: 7.0)
        let remove = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([followPath, remove]))
    }
    
    //create and return a bezier curved path
    func createBezier() -> CGPath{
        let yMax = -1.0 * self.size.height
        //Bezier path was produced the PaintCode app
        //www.paintcodeapp.com
        //Use UIBezierPath class to build an object that adds points with two control points each to construnct a curved path
        let bezierPath = UIBezierPath()
        
        bezierPath.move(to: CGPoint(x:0.5, y: -0.5))
        
        bezierPath.addCurve(to: CGPoint(x:-2.5,y: -59.5), controlPoint1: CGPoint(x:0.5,y: -0.5), controlPoint2: CGPoint(x:4.55, y:-29.48))
        
        bezierPath.addCurve(to: CGPoint(x:-27.5,y: -154.5), controlPoint1: CGPoint(x:-9.55,y: -89.52), controlPoint2: CGPoint(x:-43.32,y: -115.43))
        
        bezierPath.addCurve(to: CGPoint(x:30.5,y: -243.5), controlPoint1: CGPoint(x:-11.68,y: -193.57), controlPoint2: CGPoint(x:17.28,y: -186.95))
        
        bezierPath.addCurve(to: CGPoint(x:-52.5,y: -379.5), controlPoint1: CGPoint(x:43.72, y:-300.05), controlPoint2: CGPoint(x:-47.71,y: -335.76))
        
        bezierPath.addCurve(to: CGPoint(x:54.5, y:-449.5), controlPoint1: CGPoint(x:-57.29,y: -423.24), controlPoint2: CGPoint(x:-8.14, y:-482.45))
        
        bezierPath.addCurve(to: CGPoint(x:-5.5,y: -348.5), controlPoint1: CGPoint(x:117.14,y: -416.55), controlPoint2: CGPoint(x:52.25,y: -308.62))
        
        bezierPath.addCurve(to: CGPoint(x:10.5,y: -494.5), controlPoint1: CGPoint(x:-63.25, y:-388.38), controlPoint2: CGPoint(x:-14.48,y: -457.43))
        
        bezierPath.addCurve(to: CGPoint(x:0.5,y: -559.5), controlPoint1: CGPoint(x:23.74,y: -514.16), controlPoint2: CGPoint(x:6.93,y: -537.57))
        
        
        bezierPath.addCurve(to: CGPoint(x:-2.5, y:yMax), controlPoint1: CGPoint(x:-5.2,y: yMax), controlPoint2: CGPoint(x:-2.5, y:yMax))
        return bezierPath.cgPath
        
    }
    //create a powerup sprite that spins and moves from top to bottom
    //
    func dropWeaponsPowerUp(){
        let sideSize = 30.0
        
        //Determine the staring x-position for the weapons power up
        let startX = Double(arc4random_uniform(uint(self.size.width - 60)) + 30)
        
        //starting y position above the screen
        let startY = Double(self.size.height) + sideSize
        
        //create our powerUp sprite and set its properties
        
        let powerUp = SKSpriteNode(imageNamed: "powerup")
        powerUp.size = CGSize(width: sideSize, height: sideSize)
        powerUp.position = CGPoint(x: startX, y: startY)
        
        powerUp.name = PowerupNodeName
        
        self.addChild(powerUp)
        
        let powerUpPath = createBezier()
        
        let followPath = SKAction.follow(powerUpPath, asOffset: true, orientToPath: true, duration: 5.0)
        let remove = SKAction.removeFromParent()
        powerUp.run(SKAction.sequence([followPath, remove]))
    }
    func dropShipPowerUp(){
        let sideSize = 30.0
        
        //Determine the staring x-position for the weapons power up
        let startX = Double(arc4random_uniform(uint(self.size.width - 60)) + 30)
        
        //starting y position above the screen
        let startY = Double(self.size.height) + sideSize
        
        //create our powerUp sprite and set its properties
        
        let shipPowerUp = SKSpriteNode(imageNamed: "powerupShip")
        shipPowerUp.size = CGSize(width: sideSize, height: sideSize)
        shipPowerUp.position = CGPoint(x: startX, y: startY)
        
        shipPowerUp.name = ShipPowerupNodeName
        
        self.addChild(shipPowerUp)
        
        let powerUpPath = createBezier()
        
        let followPath = SKAction.follow(powerUpPath, asOffset: true, orientToPath: true, duration: 5.0)
        let remove = SKAction.removeFromParent()
        shipPowerUp.run(SKAction.sequence([followPath, remove]))
    }
    func dropHealthPowerUp(){
        let sideSize = 20.0
        
        let startX = Double(arc4random_uniform(uint(self.size.width - 60)) + 30)
        
        let startY = Double(self.size.height) + sideSize
        
        
        let shipHealthRate = SKSpriteNode(imageNamed: "healthPowerUp")
        shipHealthRate.size = CGSize(width: sideSize, height: sideSize)
        shipHealthRate.position = CGPoint(x: startX, y: startY)
        
        shipHealthRate.name = HealthPowerupNodeName
        
        self.addChild(shipHealthRate)
        
        let powerUpPath = createBezier()
       
        let followPath = SKAction.follow(powerUpPath, asOffset: true, orientToPath: true, duration: 5.0)
        let remove = SKAction.removeFromParent()
        shipHealthRate.run(SKAction.group([SKAction.sequence([followPath, remove]), SKAction.fadeAlpha(to: 0.0, duration: 6.0), SKAction.scale(to: 0.5, duration: 5.0)]))
    }
    
    func checkCollisions(){
        
        if let ship = self.childNode(withName: SpaceshipNodeName){
            
            enumerateChildNodes(withName: PowerupNodeName){
                myPower, _ in
                if ship.intersects(myPower){
                    
                    if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode?{
                        
                        hud.showPowerupTimer(self.powerUpDuration)
                        
                    }
                    
                    myPower.removeFromParent()
                    //increase the ship's fire rate for a period of 5 seconds
                    self.shipFireRate = 0.1
                    //but we need to power back down after a delay so we are not unbeatable
                    let powerDown = SKAction.run{
                        self.shipFireRate = self.defaultFireRate
                    }
                    //now lets setup a delay before the powerdown occurs
                    let wait = SKAction.wait(forDuration: self.powerUpDuration)
                    
                    let waitAndPowerDown = SKAction.sequence([wait, powerDown])
                    
                    //ship.run(waitAndPowerDown)
                    //if we collect an additional power up while one is already in progress we need to stop the one in progress and start a new one so we always get the full duration for the new one.
                    //Sprite kit lets us run actions with a key that we can use to identify and remove the action before it has a chance to run or before it finishes if already running.
                    
                    //if no key is found, nothing happens...
                    let powerDownActionKey = "waitAndPowerDown"
                    ship.removeAction(forKey: powerDownActionKey)
                    ship.run(waitAndPowerDown, withKey: powerDownActionKey)
                }
            }
            enumerateChildNodes(withName: ShipPowerupNodeName){
                myShipPower, _ in
                if ship.intersects(myShipPower){
                    myShipPower.removeFromParent()
                    ship.removeFromParent()
                    
                    self.shipUpgraded.position = ship.position
                    self.shipUpgraded.size = CGSize(width: 60.0, height: 60.0)
                    self.shipUpgraded.name = self.SpaceshipNodeName
                    self.addChild(self.shipUpgraded)
                    let powerDown = SKAction.run{
                        self.shipUpgraded.removeFromParent()
                        self.addChild(ship)
                        ship.position = self.shipUpgraded.position
                        self.shoot()
                    }
                    //now lets setup a delay before the powerdown occurs
                    let wait = SKAction.wait(forDuration: self.powerUpDuration)
                    
                    let waitAndPowerDown = SKAction.sequence([wait, powerDown])
                    
                    let powerDownActionKey = "waitAndPowerDown"
                    ship.removeAction(forKey: powerDownActionKey)
                    self.shipUpgraded.run(waitAndPowerDown, withKey: powerDownActionKey)
                }
            }
            enumerateChildNodes(withName: HealthPowerupNodeName){
                myHealthPower, _ in
                if ship.intersects(myHealthPower){
                    myHealthPower.removeFromParent()
                     if self.shipHealthRate == 3{
                        self.shipHealthRate += 1
                        self.shield.removeFromParent()
                        ship.addChild(self.shield)
                        
                    }else if self.shipHealthRate == 2{
                        self.shipHealthRate += 2
                        self.shield2.removeFromParent()
                        ship.addChild(self.shield)
                    }else if self.shipHealthRate == 1{
                        self.shipHealthRate += 3
                        ship.addChild(self.shield)
                    }
                
                    
                }
                    
                    
                
            }
            //this method will enumerate(loop) through the scene graph node tree looking for any node with a name of obsticle if it finds one it automatically populates my obsticle with a referance. I loops throgh the entire node tree.
            enumerateChildNodes(withName: ObstacleNodeName){
                myObsticle, _ in
                
                //check for collision with our ship
                if ship.intersects(myObsticle){
                    //our ship collided with our obsticle
                    self.shipHealthRate -= 1
                   
                    myObsticle.removeFromParent()
                    self.run(self.obsticleExplodeSound)
                    let explosion = self.obsticleExplodeTemplate.copy() as! SKEmitterNode
                    explosion.position = myObsticle.position
                    explosion.dieOutInDuration(0.1)
                    self.addChild(explosion)
                    
                    if self.shipHealthRate == 2{
                        self.shield.removeFromParent()
                        ship.addChild(self.shield2)
                        
                    }else{
                        self.shield2.removeFromParent()
                    }
                    
                }
                if self.shipHealthRate == 0{
                    
                    
                    //set our shipTouch property to nil so it will not be used by oue shooting logic in the update() method to continue to track ths touch and shoot a photon topedo.
                    //If this doesn't work the torpedo would still shoot form (0,0) since the ship is gone.
                    self.shipTouch = nil
                    // Call copy() one the node in the shipExplode propertu becasue nodes can only be add to a scene once.
                    
                    //if we tru to ad a node again that already exists in a scene the game will creash with an error.  We will use the emitter node template in our cached property as a template
         
                    
                    let explosion = self.shipExplodeTemplate.copy() as! SKEmitterNode
                    
                    explosion.position = ship.position
                    explosion.dieOutInDuration(0.3)
                    self.addChild(explosion)
                    
                    //remove the ship and obsticle
                    ship.removeFromParent()
                    myObsticle.removeFromParent()
                    self.run(self.shipExplodeSound)
                    
                    if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode?{
                        
                        hud.endGame()
                        
                    }
                    
                }
                
                
                //now add an inner loop that enumerates through the photon torpedo nodes and checks if any collides with myObsticle
                
                
                self.enumerateChildNodes(withName: self.PhotonTorpedoNodeName){
                    myPhoton, stop in
                    
                    if myPhoton.intersects(myObsticle){
                        myPhoton.removeFromParent()
                        
                        myObsticle.removeFromParent()
                        
                        self.run(self.obsticleExplodeSound)
                        
                        let explosion = self.obsticleExplodeTemplate.copy() as! SKEmitterNode
                        
                        //Update our score
                        if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode?{
                            
                            let score = 100
                            hud.addPoints(score)
                            
                        }
                        
                        explosion.position = myObsticle.position
                        explosion.dieOutInDuration(0.1)
                        self.addChild(explosion)
                        //set stip.pointee to true to end this inner loop
                        //
                        //this is like a break statmenet in other languages
                        
                        stop.pointee = true
                        
                    }
                    
                }
            }
            
                self.enumerateChildNodes(withName: self.PacmanNodeName){
                    pman, _ in
                    self.enumerateChildNodes(withName: self.ObstacleNodeName){
                        myObsticle, _ in
                        if ship.intersects(pman){
                            self.shipHealthRate -= 2
                            
                            if self.shipHealthRate == 2{
                                self.shield.removeFromParent()
                                ship.addChild(self.shield2)
                                
                            }else{
                                self.shield2.removeFromParent()
                            }
                        }
                        if self.shipHealthRate == 0{
            
                            self.shipTouch = nil
                            
                            
                            let explosion = self.shipExplodeTemplate.copy() as! SKEmitterNode
                            
                            explosion.position = ship.position
                            explosion.dieOutInDuration(0.3)
                            self.addChild(explosion)
                            
                            
                            self.run(self.shipExplodeSound)
                           
                                if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode?{
                                    hud.endGame()
                                }
                           
                        }
                    if pman.intersects(myObsticle){
                        myObsticle.removeFromParent()
   
                        self.run(self.obsticleExplodeSound)
                        
                        let explosion = self.obsticleExplodeTemplate.copy() as! SKEmitterNode
                        explosion.position = myObsticle.position
                        explosion.dieOutInDuration(0.1)
                        self.addChild(explosion)
                        
                    }}
                self.enumerateChildNodes(withName: self.PhotonTorpedoNodeName){
                    myPhoton, stop in
                    if myPhoton.intersects(pman){
                        self.pmanHealth -= 1
                        myPhoton.removeFromParent()
                    }
                    if self.pmanHealth == 0{
                        myPhoton.removeFromParent()
                        pman.removeFromParent()
                        
                        self.run(self.shipExplodeSound)
                        
                        let explosion = self.shipExplodeTemplate.copy() as! SKEmitterNode
                        
                        //Update our score
                        if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode?{
                            
                            let score = 200
                            hud.addPoints(score)
                            
                        }
                        
                        explosion.position = pman.position
                        explosion.dieOutInDuration(0.1)
                        self.addChild(explosion)
                    }
                    stop.pointee = true
                }
            }
        }
    }
    
}



