//
//  StartGame.swift
//  Dodger Me!
//
//  Created by Guan Wong on 2/3/15.
//  Copyright (c) 2015 Guan Wong. All rights reserved.
//


/*
THIS IS WHEN THE GAME START


*/


import SpriteKit
import iAd
//import UIKit


/*
**  For colision detection
**
*/
struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let Imune       : UInt32 = UInt32.max
    static let Player   :UInt32 = 0b1
    static let Fire   : UInt32 = 0b10
    static let Dragon : UInt32 = 0b100
    static let Food : UInt32 = 0b1000
    
}

/*  NEW ADDED 11/29/2015
**
** Now the player has a struct
** Easier to manage the player
*/
struct Player{
    var HP:Int?
    var isInvincible:Bool?
    var playerImage:SKSpriteNode
    var isTouched:Bool = false
}

/*
**  Extension is to extend the struct
** Added to practice it.. since it might be useful in later apps
*/
extension Player{
    init (playerImage:SKSpriteNode){
        self.playerImage = SKSpriteNode()
    }
    func load(){
        // in the future... i can use like load("name of image")
        self.playerImage.size = CGSize(width: 30, height: 30)
        self.playerImage.texture = SKTexture(imageNamed: "sprites/player/player_full")
        self.playerImage.name = "player"
        self.playerImage.position = CGPointMake( 0, 0)
    }
    func materializeBody(){
        // Setting a physical body to the player
        playerImage.physicsBody = SKPhysicsBody(rectangleOfSize: playerImage.size)
        playerImage.physicsBody?.dynamic = true
        playerImage.physicsBody?.categoryBitMask = PhysicsCategory.Player
        playerImage.physicsBody?.collisionBitMask = PhysicsCategory.None
    }
}


struct Object{
   
    var objImage:SKSpriteNode = SKSpriteNode()
    var type:Int?;
    var delay:CGFloat = 0.0  // delay for spawining the object
    var current_speed:CGFloat = 1   // initial/current speed
    var max_speed:CGFloat = 0.4
    
    
  /*  init (imgName:String){
        self.objImage.size = CGSize(width: 20, height: 20)
        self.objImage.texture = SKTexture(imageNamed: "\(imgName)")
        self.objImage.name = "unknownForNow"
        self.objImage.position = CGPointMake( 0, 0)
    }*/
    
    mutating func incDelay(amount:CGFloat){
        delay += amount
    }
    mutating func resetDelay(){
        delay = 0.0
    }
}

struct PowerUPS{
    var object:Object
    var isRightArrowEnabled = false
    var isLeftArrowEnabled = false
    var isUpArrowEnabled = false
    var isDownArrowEnabled = false
    var isImuneItemEnabled = false
    
    var buffTime_Up:CGFloat = 0
    var buffTime_Down:CGFloat = 0
    var buffTime_Left:CGFloat = 0
    var buffTime_Right:CGFloat = 0
    var buffTime_imune:CGFloat = 0
  
    
    
    init (){
 object = Object()
    }
    
    mutating func update(){
        if (buffTime_Up <= 0){
            isUpArrowEnabled = false
        }
        
        if (buffTime_Down <= 0 ){
            isDownArrowEnabled = false
        }
        
        if (buffTime_Left <= 0 ){
            isLeftArrowEnabled = false
        }
        
        if (buffTime_Right <= 0 ){
            isRightArrowEnabled = false
        }
        
        if (buffTime_imune <= 0 ){
            isImuneItemEnabled = false
        }
        
    }
    
}
/*
** Below I am using the mutating function
** Struct is a value type, and itself is immutable, thus, if we want to
** change the value we have to use the mutating func
** Note: Class = reference type ,  Struct = Value type
*/
struct Scorelabel{
    var node:SKLabelNode =  SKLabelNode(fontNamed: "Courier")  // score board
    var score = 0
    
    func load(){
        // load score
        node.text = "\(score)"
        node.name = "scoring"
        node.fontSize = 20
        node.fontColor = SKColor.blackColor()
        node.position = CGPoint(x:-130, y:320)
    }
    
    mutating func setScore(){
        //set score and display it
        score = score + 10
        node.text = "\(score)"
    }
}
//

class StartGame: SKScene, SKPhysicsContactDelegate, ADBannerViewDelegate, UnpauseDelegate, ADInterstitialAdDelegate{
    
   deinit{
        print("startgame is being deInitialized.");
    }
    
    
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate // Create reference to the app delegate
    var interstitialAds:ADInterstitialAd = ADInterstitialAd()
    var interstitialAdView: UIView = UIView()
    var pauseGameViewController = PauseMenu()
    var bgImage = SKSpriteNode(imageNamed: "sprites/background2.png")
    var startCountLabel = SKLabelNode(fontNamed: "Courier")
    
    // This will fix the BUG from interstitial ads when not clicked
    var gameover:Bool = false
    
    
    
    var gameMode:String? = nil;   // current Level -> this is set up by level selector
    var scorePass:Int? = nil;    // minumum score to pass to next level
    
    
    var highscore:Int = 0
    var timerCount:Int = 3
    
    
    // Implemented Scorelabel Class
    var scoreBoard = Scorelabel()
    
    // Implemented Player class
    var player = Player(playerImage: SKSpriteNode()) // using extension way
    
    // Implemented Enemy class 12/15/2015
    var fire = Object()
    var dragon = Object()
    var powerUp = PowerUPS()
    
    // Implemented "constant" values for differents modes 12/18/2015
    var CHANCE_OF_POWERUP:CGFloat? // Percentage of respawing each second
    var MAX_FIRE_SPEED:CGFloat?
    var MAX_DRAGON_SPEED:CGFloat?
    var RESPAWN_DRAGON_SCORE:Int?
    var RATE_SPEED_GROWTH:CGFloat?
    
    
    
    override func didMoveToView(view: SKView){
        
      //  print("screen width: \(self.appDelegate.screenSize.width)\n")
      //  print("screen height: \(self.appDelegate.screenSize.height)")
        
        
        // delete subviews if previous didnt called
        for view in view.subviews {
            view.removeFromSuperview()
        }
        
        self.anchorPoint = CGPointMake(0.5, 0.5)
        
        //Implemented usage of plist 12/19/2015
       // getValuesInPlistFile()
        
        //load stage settings
        
        // 1.Classic
        if(gameMode! == "classic"){
            
            CHANCE_OF_POWERUP = 10
            MAX_FIRE_SPEED = 0.4
            MAX_DRAGON_SPEED = 1.5
            RESPAWN_DRAGON_SCORE = 40000
            RATE_SPEED_GROWTH = 0.01
            scorePass = 50000
            
        }
        // 2.Insane
        else if(gameMode! == "insane"){
            CHANCE_OF_POWERUP = 15
            MAX_FIRE_SPEED = 0.2
            MAX_DRAGON_SPEED = 1.0
            RESPAWN_DRAGON_SCORE = 30000
            RATE_SPEED_GROWTH = 0.03
            scorePass = 40000
        }
        
        
        // load ads
        loadiAd()
        // load objects
        load();
        
        
        // Counts from 3 to 0 and starts showing enemies
      startCountLabel.runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(startCount),
                SKAction.waitForDuration(NSTimeInterval(1)), SKAction.scaleTo(1.0, duration: 0.2)
                ])
            ), withKey: "start_count")
    
        
    }
    
    func getValuesInPlistFile(){
    
        // this works -- RETRIEVING STUFF FROM THE DEFAULT PLIST ( CAN BE USED FOR RESET )
        /*
        let filePath = NSBundle.mainBundle().pathForResource("dodger", ofType: "plist")!
        let stylesheet = NSDictionary(contentsOfFile:filePath)
        let filename = "Highscore_Classic"
        let hs:Double = stylesheet!.valueForKeyPath(filename) as! Double
        print("finally we got this: \(hs)")*/
        
    }
        
    
    
    func loadiAd(){
  
        // delegate for Unpause scene
        pauseGameViewController.delegate = self
       
           //iAd Banner
        //self.appDelegate.adBannerView.delegate = self  // -> to avoid an error
        
        //hide until ad loaded
        
        //self.appDelegate.adBannerView.hidden = false
        self.appDelegate.adBannerView = ADBannerView(frame: CGRect.zero)
        self.appDelegate.adBannerView.center = CGPoint(x: self.appDelegate.adBannerView.center.x, y: view!.bounds.size.height - self.appDelegate.adBannerView.frame.size.height / 2)
        self.appDelegate.adBannerView.delegate = self
        self.appDelegate.adBannerView.hidden = true
        view!.addSubview(self.appDelegate.adBannerView)
        
        
        // iAD  Interstitial  -> pop up full screen iAds
        self.interstitialAdView.frame = self.view!.bounds
        self.interstitialAds.delegate = self
        self.interstitialAdView.hidden = true
       
        view!.addSubview(self.interstitialAdView)
        
    }
    func load(){
        
        //load background
        self.bgImage.size = self.frame.size
        self.bgImage.position = CGPointMake( 0, 0)
        self.bgImage.name = "bground"
        self.addChild(bgImage)
        
        // load startTimeLabel
        startCountLabel.hidden = true
        startCountLabel.text = "\(timerCount)"
        startCountLabel.name = "scoring"
        startCountLabel.fontSize = 200
        startCountLabel.fontColor = SKColor.blackColor()
        startCountLabel.position = CGPoint(x:0, y:50)
        self.addChild(startCountLabel)
        
        // load score
        
        scoreBoard.load()
        self.addChild(scoreBoard.node)
        
        // load player
        player.HP = 3
        player.load()
        player.materializeBody()
        player.isInvincible = false
        self.addChild(player.playerImage)
        
        // applying physics
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
    }
    
    func testSprite() -> [SKTexture]{
  
        //testing
       // dragonMonster.texture = SKTexture(imageNamed: "sprites/draggy/d_001")
        //ends
        return [SKTexture(imageNamed: "sprites/draggy/d_001"), SKTexture(imageNamed: "sprites/draggy/d_002"), SKTexture(imageNamed: "sprites/draggy/d_003"), SKTexture(imageNamed: "sprites/draggy/d_004")]
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            
            
            let location = (touch ).locationInNode(self)
            if ( ((player.playerImage.position.x > location.x - 20 ) && (player.playerImage.position.x < location.x + 20)) && ((player.playerImage.position.y > location.y - 20 ) && (player.playerImage.position.y < location.y + 20))  ){
               if (self.player.isInvincible == false){
                let liftUp = SKAction.scaleTo(1.2, duration: 0.2)
                player.playerImage.runAction(liftUp)}
                player.isTouched = true
                
            }
            else{
                player.isTouched  = false
            }
            
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = (touch ).locationInNode(self)
            if (player.isTouched){
                
                player.playerImage.position = location
                
                if ( player.playerImage.position.y > self.appDelegate.screenSize.height/2 * 0.815){
                    player.playerImage.position.y = self.appDelegate.screenSize.height/2 * 0.815
                }
                else if ( player.playerImage.position.y < -self.appDelegate.screenSize.height/2 * 0.815){
                    player.playerImage.position.y = -self.appDelegate.screenSize.height/2 * 0.815
                }
                if ( player.playerImage.position.x < -self.appDelegate.screenSize.width/2 * 0.735){
                    player.playerImage.position.x = -self.appDelegate.screenSize.width/2 * 0.735
                }
                else if ( player.playerImage.position.x > self.appDelegate.screenSize.width/2 * 0.745){
                    player.playerImage.position.x = self.appDelegate.screenSize.width/2 * 0.745
                }
                
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for _ in touches {
            if (self.player.isInvincible == false){
            let liftUp = SKAction.scaleTo(1.0, duration: 0.2)
            player.playerImage.runAction(liftUp)
            }
        }
    }
    
    
    // iAd functions
    
 
    func bannerViewWillLoadAd(banner: ADBannerView!) {
        // about to load a new ads
        
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        self.appDelegate.adBannerView.hidden = false
        
        
     //   print("iAD banner didload")
    }
    
    func bannerViewActionDidFinish(banner: ADBannerView!) {
        //self.appDelegate.adBannerView.removeFromSuperview()
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        
        // when banner begins -> pause game
        self.appDelegate.adBannerView.hidden = true
        pauseGame()
        return true
        
        
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        
        //when fails to call banner it will call this function
    }
    
    
    // finish iAd functions
    
    
    // iAD interstitial pop up
    
    func interstitialAdWillLoad(interstitialAd: ADInterstitialAd!) {
    }
    
    func interstitialAdDidLoad(interstitialAd: ADInterstitialAd!) {
    }
    
    func interstitialAdActionDidFinish(interstitialAd: ADInterstitialAd!) {
        // it is always called when at the start.. why?
       // print("is it called twice?")
        if(self.interstitialAds.loaded){
            callUnpause()  // check later if this is necessary
            self.interstitialAdView.removeFromSuperview()
            castEndScene()
           
        }
        
    }
    
    func interstitialAdActionShouldBegin(interstitialAd: ADInterstitialAd!, willLeaveApplication willLeave: Bool) -> Bool {
        // actions to happen when user click on iAD
       // castEndScene()
        return true
    }
    
    func interstitialAd(interstitialAd: ADInterstitialAd!, didFailWithError error: NSError!) {
        //action if Ads can't load
        print("failed to start iAD fullscreen")
        
        // if game is over... cast end scene
        if (gameover){
            castEndScene()
        }
    }
    
    func interstitialAdDidUnload(interstitialAd: ADInterstitialAd!) {
        self.interstitialAdView.removeFromSuperview()
        self.interstitialAdView.hidden = true
    }
    
    // finish iAd pop up functions
    
    
    
    // good function helper for random a CGFloat datatype
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random( min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    
    func loadObjects(){
    fire.type = 0
    fire.current_speed = 1.0
    fire.max_speed = MAX_FIRE_SPEED!
        
    dragon.type = 1
    dragon.current_speed = 1.5
    dragon.max_speed = MAX_DRAGON_SPEED!
    powerUp.object.type = 2
        
        
        //keep calling callFire()
            runAction(SKAction.repeatActionForever(
                SKAction.sequence([
                    SKAction.runBlock({self.callType(self.fire)}),
                    SKAction.waitForDuration(NSTimeInterval(0.1))
                    ])
                ), withKey: "fire_attack")
        
    
        //keep calling callDragon

         //   removeActionForKey("dragon_attack")
            runAction(SKAction.repeatActionForever(
                SKAction.sequence([
                    SKAction.runBlock({self.callType(self.dragon)}),
                    SKAction.waitForDuration(NSTimeInterval(0.1))
                    ])
                ), withKey: "dragon_attack")
        
        // for food
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock({self.callType(self.powerUp.object)}),
                SKAction.waitForDuration(NSTimeInterval(1))
                ])
            ), withKey: "respawn_powerups")
        
    }
    
 
    func startCount(){
        startCountLabel.hidden = false
        let liftUp = SKAction.scaleTo(0.5, duration: 0.2)
        startCountLabel.runAction(liftUp)
        startCountLabel.text = "\(timerCount)"
        if ( timerCount == 0){
            startCountLabel.text = "START!"
            scoreStartCounting()
        }
        else if (timerCount == -1){
             startCountLabel.removeActionForKey("start_count")
            // Load all enemies/bonus items
             loadObjects()
            startCountLabel.removeFromParent()
        }
        
        timerCount--
       
    }
    
    func scoreStartCounting(){
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(setScore), SKAction.waitForDuration(NSTimeInterval(0.01))])), withKey: "scoreCounter")
    }
    
    func setScore(){
        scoreBoard.setScore()
    }
    
    func callType(obj: Object){
        
        // fireball
        if ( obj.type == 0){
            
            // increase level of difficulty
            if ( obj.current_speed > obj.max_speed ){
                fire.current_speed -= RATE_SPEED_GROWTH!
            }
            
            fire.incDelay(0.2)
            
            if (obj.delay >= obj.current_speed){
                callFire();
                fire.resetDelay()
            }
            
           // print("current level: \(obj.current_speed)")
        }
            // dragons
        else if (obj.type == 1){
            dragon.incDelay(0.2)
            if (obj.delay >= obj.current_speed && scoreBoard.score >= RESPAWN_DRAGON_SCORE){
                
                //increase dragon speed
                if ( obj.current_speed > obj.max_speed ){
                    dragon.current_speed -= RATE_SPEED_GROWTH!
                }
                
                callDragon()
               dragon.resetDelay()
            }
        }
        
            // powerups
        else if (obj.type == 2){
            let ram = random(0, max:100)
            if(ram > 100 - CHANCE_OF_POWERUP!){
            callPowerUp()
            }
        }
        
        
    }
    func callFire() {
        
        //self.s = self.delta
        // Create sprite
        let fireball = SKSpriteNode(imageNamed: "sprites/fireball/fireBall")
        fireball.name = "spriteFire"
        fireball.size = CGSize(width: 15, height: 15)
        
        // destination
        let y_up_bound:CGFloat = self.appDelegate.screenSize.height/2
        let y_down_bound:CGFloat = -self.appDelegate.screenSize.height/2
        let x_left_bound:CGFloat = -self.appDelegate.screenSize.width/2
        let x_right_bound:CGFloat = self.appDelegate.screenSize.width/2
        var x_togo:CGFloat = 0
        var y_togo:CGFloat = 0
        var angle:CGFloat = 0 // angular coefficient that passes through player
        var b:CGFloat = 0     // the b from y = a+b
        
        // Giving a initial random position ( x and y )
        var x_respawn = random( x_left_bound, max: x_right_bound)
        var y_respawn = random( y_down_bound, max: y_up_bound)
        let option = Int(arc4random_uniform(4))

        
        // Determine where to spawn the monster along the Y axis
       
        // Position of the fireball to respawn:
        
        // Respawn bottom
        if ( Int(option) == 0 ){
            if(powerUp.isRightArrowEnabled == true){
                return
            }
            fireball.position = CGPoint(x: x_respawn, y: y_down_bound)
            y_respawn = y_down_bound
        }
        
        // Respawn Top
        else if ( Int(option) == 1 ){
            if(powerUp.isUpArrowEnabled == true){
                return
            }
            fireball.position = CGPoint(x: x_respawn, y: y_up_bound)
            y_respawn = y_up_bound
        }
            
        //Respawn Left
        else if ( Int(option) == 2 ){
            if(powerUp.isLeftArrowEnabled == true){
                return
            }
            fireball.position = CGPoint(x: x_left_bound, y: y_respawn)
            x_respawn = x_left_bound
        }
            
        //Respawn Right
        else if ( Int(option) == 3 ){
            if(powerUp.isRightArrowEnabled == true){
                return
            }
            fireball.position = CGPoint(x: x_right_bound, y: y_respawn)
            x_respawn = x_right_bound
        }
        
        // Add to scene
        addChild(fireball)
        
        
        // adding physical body
        
        fireball.physicsBody = SKPhysicsBody(circleOfRadius: fireball.size.width/2) // 1
        fireball.physicsBody?.dynamic = true // physic engine will not control the movement of the fireball
        fireball.physicsBody?.categoryBitMask = PhysicsCategory.Fire // category of bit I defined in the struct
        fireball.physicsBody?.contactTestBitMask = PhysicsCategory.Player // notify when contact Player
        fireball.physicsBody?.collisionBitMask = PhysicsCategory.None // this thing is related to bounce
        fireball.physicsBody?.usesPreciseCollisionDetection = true
        
        // calculate the destination position
        
        
        // 1. Getting the final destination of coordinate y or x :
        
        if ( (Int(option) == 0) || (Int(option) == 1)  )
        {
            y_togo = y_respawn*(-1)
        }
            
            
        else if ( (Int(option) == 2) || (Int(option) == 3)  ){
            x_togo = x_respawn*(-1)
            
        }
        
        // 2. Calculate the angular coefficient
        
        angle = (player.playerImage.position.y - y_respawn)/(player.playerImage.position.x - x_respawn) //  angle = (y - yi ) / ( x - xo )
        b = y_respawn - angle*x_respawn // finding b from y = ax + b,  b = y - ax
        
        
        // 3. finding the second line which will intersect with previous line
        
        if ( (Int(option) == 0) || (Int(option) == 1)  )
        {
            x_togo = (y_togo - b)/angle // finding x final, x= ( y - b )/a
            
            if ( x_togo > 200 ){
                x_togo = 200
            }
            else if (x_togo < -200){
                x_togo = -200
            }
            
        }
            
            
        else if ( (Int(option) == 2) || (Int(option) == 3)  ){
            y_togo = angle*x_togo + b // finding y final,  y = ax + b
            
            
            if ( y_togo > 355 ){
                y_togo = 355
            }
            else if (y_togo < -355){
                y_togo = -355
            }
        }
        
        
        // end calculation
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: x_togo, y: y_togo), duration: 5)
        let actionMoveDone = SKAction.removeFromParent()
        fireball.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    func callDragon(){
        
        // Create sprite
        let dragonMonster = SKSpriteNode(imageNamed: "dragons")
        
        dragonMonster.name = "spriteFire"
        dragonMonster.size = CGSize(width: 20, height: 20)
        
        // random Y position respawn
        let y_respawn = random( -355, max: 355)
        
        // destination
        let x_left_bound:CGFloat = -200
        let x_right_bound:CGFloat = 200
        
        dragonMonster.position = CGPoint(x: x_left_bound, y: y_respawn)
        
        // both side if score greater than 10000
        if (scoreBoard.score >= 10000){
            let rVal:CGFloat = random(0, max:1000)
            
            if (rVal > 500){
                dragonMonster.xScale = dragonMonster.xScale * -1;
                dragonMonster.position = CGPoint(x: x_right_bound, y: y_respawn)
            }
        }
        
        addChild(dragonMonster)
        
        // adding physical stuff  -> create a function for that later
        
        dragonMonster.physicsBody = SKPhysicsBody(circleOfRadius: dragonMonster.size.width/2) // 1
        dragonMonster.physicsBody?.dynamic = true // physic engine will not control the its movement
        dragonMonster.physicsBody?.categoryBitMask = PhysicsCategory.Dragon // category of bit I defined in the struct
        dragonMonster.physicsBody?.contactTestBitMask = PhysicsCategory.Player // notify when contact Player
        dragonMonster.physicsBody?.collisionBitMask = PhysicsCategory.None // this thing is related to bounce
        dragonMonster.physicsBody?.usesPreciseCollisionDetection = true
        
        // Create the actions
        
        // by default
        var actionMove = SKAction.moveTo(CGPoint(x: x_right_bound, y: y_respawn), duration: 5)
        
        if (dragonMonster.position.x == 200){
          actionMove = SKAction.moveTo(CGPoint(x: x_left_bound, y: y_respawn), duration: 5)
        }
        
        let actionMoveDone = SKAction.removeFromParent()
        let walk = SKAction.animateWithTextures(testSprite(), timePerFrame: 0.033)
        
        dragonMonster.runAction(SKAction.repeatActionForever(walk))
        
        dragonMonster.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
        
    }
    
    func callPowerUp(){
        
        // 10% :  Imune item
        // 20% :  block side
        // 70% :  Gain HP
        
        let randomNum:CGFloat = random(0, max: 100)
        let randomArrowtype:CGFloat = random(0, max:100)
        // Create sprite
        let item = SKSpriteNode()
        
        // 10% imune
        if ( randomNum <= 10){
            item.texture = SKTexture(imageNamed: "sprites/powerUps/imuneItem")
            item.name = "spriteImune"
            item.size = CGSize(width: 20, height: 20)
        }
        
        // 20% block item
        else if ( randomNum > 10 && randomNum <= 30){
           
           
            // 30% : up/down
            // 20% : left/right
            
            if (randomArrowtype <= 30 ){
               item.texture = SKTexture(imageNamed: "sprites/powerUps/left_arrow")
                item.name = "spriteArrow_left"
            }
            
            else if (randomArrowtype > 30 && randomArrowtype <= 60 ){
                item.texture = SKTexture(imageNamed: "sprites/powerUps/right_arrow")
                item.name = "spriteArrow_right"
            }
            
            else if (randomArrowtype > 60 && randomArrowtype <= 80 ){
                item.texture = SKTexture(imageNamed: "sprites/powerUps/up_arrow")
                item.name = "spriteArrow_up"
            }
            
            else if (randomArrowtype > 80 && randomArrowtype <= 100 ){
                item.texture = SKTexture(imageNamed: "sprites/powerUps/down_arrow")
                item.name = "spriteArrow_down"
            }
            
            
            item.size = CGSize(width: 20, height: 20)
        }
        
        // 70% life item
        else {
            item.texture = SKTexture(imageNamed: "sprites/powerUps/life")
            item.name = "spriteLife"
            item.size = CGSize(width: 20, height: 20)
        }
       
       
        
        // random Y position respawn
        let y_respawn = random( -300, max: 300)
        
        // destination
        let x_respawn = random( -150, max: 150)
        
        item.position = CGPoint(x: x_respawn, y: y_respawn)
        
        addChild(item)
        
        // adding physical stuff  -> create a function for that later
        
        item.physicsBody = SKPhysicsBody(circleOfRadius: item.size.width/2) // 1
        item.physicsBody?.dynamic = true // physic engine will not control the its movement
        item.physicsBody?.categoryBitMask = PhysicsCategory.Food // category of bit I defined in the struct
        item.physicsBody?.contactTestBitMask = PhysicsCategory.Player // notify when contact Player
        item.physicsBody?.collisionBitMask = PhysicsCategory.None // this thing is related to bounce
        item.physicsBody?.usesPreciseCollisionDetection = true
        
        
    }
    
    func updatePlayerIMG(){
       
        if(player.isInvincible == true){
             self.player.playerImage.texture = SKTexture(imageNamed: "sprites/player/player_imune")
        }
        
        else{
        
        if(player.HP! == 3){
        self.player.playerImage.texture = SKTexture(imageNamed: "sprites/player/player_full")
        }
        else if(player.HP! == 2){
            self.player.playerImage.texture = SKTexture(imageNamed: "sprites/player/player_medium")
        }
        else if(player.HP! == 1){
            self.player.playerImage.texture = SKTexture(imageNamed: "sprites/player/player_low")
        }
        else{
         self.player.playerImage.texture = SKTexture(imageNamed: "sprites/player/player")
        }
            
        }
    }
    
    func projectileDidCollideWithMonster(player:SKSpriteNode, object:SKSpriteNode) {
        
        object.removeFromParent()
      //  print("Collided")
        
        if (object.name == "spriteLife"){
            self.player.HP = self.player.HP! + 1
            
            if (self.player.HP > 3 ){
            self.player.HP = 3
            }
        }
        
        else if (object.name == "spriteImune"){
            
            var tempBool:Bool = true // this is used for alpha purpose
            
            let expand = SKAction.scaleTo(2.5, duration: 0.2)
            let shrink = SKAction.scaleTo(1.0, duration: 0.2)
            let BONUS_TIME:CGFloat = 10.0
            
            self.player.playerImage.runAction(expand)
            self.player.isInvincible = true
            self.player.playerImage.alpha = 1.0
            
            if (self.powerUp.buffTime_imune <= 0 ){
                     self.powerUp.isImuneItemEnabled = true
                     self.powerUp.buffTime_imune = BONUS_TIME
                
                runAction(SKAction.repeatActionForever(
                    SKAction.sequence([
                        SKAction.runBlock({
                            self.powerUp.buffTime_imune -= 0.1
                            
                            if( self.powerUp.buffTime_imune > 0 &&  self.powerUp.buffTime_imune <= 5){
                                
                                if(tempBool == true){
                                    self.player.playerImage.alpha -= 0.1
                                    if (self.player.playerImage.alpha <= 0.5){
                                        tempBool = false
                                    }
                                }
                                else{
                                    self.player.playerImage.alpha += 0.1
                                    if (self.player.playerImage.alpha >= 1.0){
                                        tempBool = true
                                    }
                                }
                            }
                            
                            self.powerUp.update()
                            
                            if (self.powerUp.isImuneItemEnabled == false){
                                self.player.isInvincible = false
                                self.player.playerImage.alpha = 1.0
                                self.player.playerImage.runAction(shrink)
                                self.removeActionForKey("imune_counter")
                             self.updatePlayerIMG()
                            }
                            
                            }), SKAction.waitForDuration(NSTimeInterval(0.1))
                        ])
                    ), withKey: "imune_counter")
                
            }
            else {
                self.powerUp.buffTime_imune = BONUS_TIME
            }
        }
        
        else if (object.name!.containsString("spriteArrow")){
          
            let BONUS_TIME:CGFloat = 15.0
            
            if(object.name!.containsString("_right")){
                powerUp.isRightArrowEnabled = true
            }
            else if(object.name!.containsString("_left")){
                powerUp.isLeftArrowEnabled = true
            }
            else if(object.name!.containsString("_up")){
                powerUp.isUpArrowEnabled = true
            }
            else if(object.name!.containsString("_down")){
                powerUp.isDownArrowEnabled = true
            }
            
            // SKAction - run it if the action is not running
            if (self.powerUp.buffTime_Right <= 0.0 && self.powerUp.buffTime_Left <= 0.0 && self.powerUp.buffTime_Up <= 0.0 && self.powerUp.buffTime_Down <= 0.0 ){
                
                if(powerUp.isRightArrowEnabled){
                    self.powerUp.buffTime_Right = BONUS_TIME
                }
                if(powerUp.isLeftArrowEnabled){
                    self.powerUp.buffTime_Left = BONUS_TIME
                }
                if(powerUp.isUpArrowEnabled){
                    self.powerUp.buffTime_Up = BONUS_TIME
                }
                if(powerUp.isDownArrowEnabled){
                    self.powerUp.buffTime_Down = BONUS_TIME
                }
                
            runAction(SKAction.repeatActionForever(
                SKAction.sequence([
                    SKAction.runBlock({
                        
                        if(self.powerUp.isRightArrowEnabled){
                            self.powerUp.buffTime_Right -= 0.1
                        }

                        if(self.powerUp.isLeftArrowEnabled){
                            self.powerUp.buffTime_Left -= 0.1
                        }
                        if(self.powerUp.isUpArrowEnabled){
                            self.powerUp.buffTime_Up -= 0.1
                        }
                        
                        if(self.powerUp.isDownArrowEnabled){
                            self.powerUp.buffTime_Down -= 0.1
                        }
                        
                        self.powerUp.update()
                        
                        if(self.powerUp.isDownArrowEnabled == false && self.powerUp.isUpArrowEnabled == false && self.powerUp.isLeftArrowEnabled == false && self.powerUp.isRightArrowEnabled == false){
                            self.removeActionForKey("arrow_counter")
                        }
                        
                    }), SKAction.waitForDuration(NSTimeInterval(0.1))
                    ])
                ), withKey: "arrow_counter")
                
                
            }
            
            else{
                
                if(powerUp.isRightArrowEnabled){
                    self.powerUp.buffTime_Right = BONUS_TIME
                }
                if(powerUp.isLeftArrowEnabled){
                    self.powerUp.buffTime_Left = BONUS_TIME
                }
                if(powerUp.isUpArrowEnabled){
                    self.powerUp.buffTime_Up = BONUS_TIME
                }
                if(powerUp.isDownArrowEnabled){
                    self.powerUp.buffTime_Down = BONUS_TIME
                }
                
            }
            
        }
            
        else if (self.player.isInvincible == false ){
        self.player.HP = self.player.HP! - 1
        }
        
        updatePlayerIMG()
        if (self.player.HP! <= 0){
        
        // Game is over - this fix when player do not close the interstital ad
        gameover = true
        
        // remove all actions ( maybe can try remove all actions later )
       /* removeActionForKey("scoreCounter")
        removeActionForKey("fire_attack")
        removeActionForKey("dragon_attack")
        removeActionForKey("respawn_powerups")
        removeActionForKey("imune_counter")
        removeActionForKey("imune_counter")*/
        removeAllActions()
        
        // remove the strong reference
        //Questions: Why I do not need to do this to other delegates such as:
        // *physical delegate, ad delegate? :/
        // Example: the pauseGameController MUST have. Otherwise, it will cause memory leak
        // But.. the others will not cause memory leak
        pauseGameViewController.delegate = nil
            
        // show iAd Pop up - if it is loaded successfully
            
            let chance_toShow:CGFloat = random(0, max: 100)
        if (self.interstitialAds.loaded && chance_toShow > 70){
            view?.paused = true
            iAdPopup()
        }
        else{
            castEndScene()
        }
            
        }
        
        
    }
    
    func castEndScene(){
        
        //removeActionForKey("scoreCounter")
        
        SKAction.waitForDuration(5)
        //  let reveal = SKTransition.flipHorizontalWithDuration(0.5)
        
        
               if ( scoreBoard.score >= scorePass!){
                let winScene = GameOver(size: self.size, won: true, score: scoreBoard.score, highscore: highscore, game_mode: self.gameMode!)
            self.view?.presentScene(winScene)
        }
            
        else{
                let loseScene = GameOver(size: self.size, won: false, score: scoreBoard.score, highscore: highscore, game_mode:gameMode!)
            self.view?.presentScene(loseScene)
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        
        var firstBody: SKPhysicsBody  // player
        var secondBody: SKPhysicsBody // fireball
        
    //    print("the body A: \(contact.bodyA.categoryBitMask)")
     //   print("the body B: \(contact.bodyB.categoryBitMask)")
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        
        
     //   if ((firstBody.categoryBitMask & PhysicsCategory.Player != 0) &&
     //       (secondBody.categoryBitMask & PhysicsCategory.Fire != 0)) {
                projectileDidCollideWithMonster(firstBody.node as! SKSpriteNode, object: secondBody.node as! SKSpriteNode)
     //   }
        
    }
    
    func iAdPopup(){
        self.interstitialAds.presentInView(self.interstitialAdView)
        UIViewController.prepareInterstitialAds()
        self.interstitialAdView.hidden = false
    }
    
    func pauseGame (){
        
        view?.paused = true
        view?.addSubview(pauseGameViewController.view)
    }
    
    // this is also called by delegate
    func callUnpause(){
        
        view?.paused = false
    }
    
    func removeAds(){
        //  self.appDelegate.interstitialAdView.removeFromSuperview()
        self.appDelegate.adBannerView.removeFromSuperview()
    }
}