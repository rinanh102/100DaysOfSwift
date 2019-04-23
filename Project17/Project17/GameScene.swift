//
//  GameScene.swift
//  Project17
//
//  Created by henry on 21/04/2019.
//  Copyright © 2019 HenryNguyen. All rights reserved.
//

import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate {
 
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    
    let possibleEmenies = ["ball", "hammer", "tv"]
    var isGameOver = false
    var gameTimer : Timer?
    var enemyTimeInterval = 1.0
    var enemyGenerated = 0
    
    var score = 0 {
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        // forced unwrap, we know the files is already here
        starfield = SKEmitterNode(fileNamed: "Starfield")!
        starfield.position = CGPoint(x: 1024, y: 384)
        starfield.advanceSimulationTime(10)
        addChild(starfield)
        starfield.zPosition = -1
        
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1  // 1 means the other things when collide
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        
        score = 0
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
     
        
               startTimer()
    }
    @objc func createEnemy(){
        if !isGameOver {
            guard let enemy = possibleEmenies.randomElement() else { return }
            
            let sprite = SKSpriteNode(imageNamed: enemy)
            sprite.position = CGPoint(x: 1200, y: Int.random(in: 20...736))
            addChild(sprite)
            
            // use per-pixel collision
            sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
            sprite.physicsBody?.categoryBitMask = 1 //Category bitmasks describe what kind of object the physics body is
            // Apply force in the left direction
            sprite.physicsBody?.velocity = CGVector(dx: -150, dy: 0)
            
            // Apply spin
            sprite.physicsBody?.angularVelocity = 5
            
            // How fast things slow down over time: 0 never
            sprite.physicsBody?.linearDamping = 0
            
            // How fast things stop rotating over time: 0 never
            sprite.physicsBody?.angularDamping = 0
            
            //TODO: Challenges 2:  after 20 enemies have been made subtract 0.1 seconds
            enemyGenerated += 1
            if enemyGenerated.isMultiple(of: 20){
                enemyTimeInterval -= 0.1
                startTimer()
        }
            
       
        }
    }
    
    //MARK: when propertis are updated
    // The update() method is called once every frame, and lets us make changes to our game.
   // Try not to do too much work, because it can slow your game down.
    override func update(_ currentTime: TimeInterval) {
        for node in children{
            if node.position.x < -300{
                node.removeFromParent()
            }
        }
        if !isGameOver{
            score += 1
        }
        
    }
    // touchesMoved() is called when an existing touch changes position
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return } // Using Set makes UITouch unique
        var location = touch.location(in: self) // figure out where on the screen user touched
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668{
            location.y = 688
        }
        player.position = location
    }
    //MARK: End Game when user hit any pieces of space debris
    func didBegin(_ contact: SKPhysicsContact) {
        if let explosion = SKEmitterNode(fileNamed: "explosion"){
            explosion.position = player.position
            addChild(explosion)
        }
        player.removeFromParent()
        isGameOver = true
    }
    
    //MARK: challenges 1
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

      
    }
    
    //MARK: Challenge 2
    func startTimer(){
      
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(timeInterval: enemyTimeInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
      
    }
    
}
