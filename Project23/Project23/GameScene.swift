//
//  GameScene.swift
//  Project23
//
//  Created by henry on 13/05/2019.
//  Copyright © 2019 HenryNguyen. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene {
    
    // a new enum that tracks what kind of enemy should be created: should we force a bomb always, should we force a bomb never, or use the default randomization?
    enum ForceBomb{
        case never, always, random
    }
    
    var gameScore : SKLabelNode!
    var score = 0 {
        didSet{
            gameScore.text = "Score: \(score)"
        }
    }
    
    var livesImage = [SKSpriteNode]()
    var lives = 3
    
    var activeSliceBG : SKShapeNode!
    var activeSliceFG : SKShapeNode!
    
    // store swipe points:
    var activeSlicePoints = [CGPoint]()
    
    //TODO:  track enemies that are currently active in the scene
    var activeEnemies = [SKSpriteNode]()
    
    //
    var isSwooshSoundActive = false
    
    //  an AVAudioPlayer property for our class that will store a sound just for bomb fuses so that we can stop it as needed.
    var bombSoundEffect : AVAudioPlayer?

    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.zPosition = -1
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        addChild(background)
        
        //The default gravity of our physics world is -0.98, which is roughly equivalent to Earth's gravity. I'm using a slightly lower value so that items stay up in the air a bit longer.
        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        physicsWorld.speed = 0.85

        createScore()
        createLives()
        createSlices()
        
    }
   
    func createScore(){
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        gameScore.position = CGPoint(x: 10, y: 10)
        score = 0
    }
    
    func createLives(){
        for i in 0..<3 {
            let spriteNode = SKSpriteNode(imageNamed: "sliceLife")
            spriteNode.position = CGPoint(x: CGFloat(834 + (i * 70)), y: 720)
            addChild(spriteNode)
            
            livesImage.append(spriteNode)
        }
    }
    //MARK:
    func createSlices(){
        //TODO: Drawing a shape in SpriteKit
        activeSliceBG = SKShapeNode()
        activeSliceFG = SKShapeNode()
        
        activeSliceBG.zPosition = 2
        activeSliceFG.zPosition = 3
        
        activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        activeSliceBG.lineWidth = 9
        
        activeSliceFG.strokeColor = UIColor.white
        activeSliceFG.lineWidth = 5
        
        addChild(activeSliceBG)
        addChild(activeSliceFG)
        
    }
    
    //
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        // Remove all existing points in the activeSlicePoints array, because we're starting fresh.
        activeSlicePoints.removeAll(keepingCapacity: true)
        
        //Get the touch location and add it to the activeSlicePoints array.
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        
        // Call the (as yet unwritten) redrawActiveSlice() method to clear the slice shapes.
        redrawActiveSlice()
        
        //Remove any actions that are currently attached to the slice shapes. This will be important if they are in the middle of a fadeOut(withDuration:) action.
        activeSliceBG.removeAllActions()
        activeSliceFG.removeAllActions()
        
        //Set both slice shapes to have an alpha value of 1 so they are fully visible.
        activeSliceBG.alpha = 1
        activeSliceFG.alpha = 1
        
    }
    
    //TODO:  method needs to do is figure out where in the scene the user touched, add that location to the slice points array, then redraw the slice shape,
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // figure out where user touched
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        // add to the array
        activeSlicePoints.append(location)
        redrawActiveSlice()
        
        if !isSwooshSoundActive {
            playSwooshSound()
        }
    }
    
    // When the user finishes touching the screen, touchesEnded() will be called.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // fade out the slice shapes over a quarter of a second.
        //run: Adds an action to the list of actions executed by the node.
        activeSliceBG.run(SKAction.fadeOut(withDuration: 0.25))
        activeSliceFG.run(SKAction.fadeOut(withDuration: 0.25))
    }
    
    // this is going to use a UIBezierPath that will be used to connect our swipe points together into a single line.
    func redrawActiveSlice(){
        //If we have fewer than two points in our array, we don't have enough data to draw a line so it needs to clear the shapes and exit the method.
        if activeSlicePoints.count < 2 {
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            return
        }

        //If we have more than 12 slice points in our array, we need to remove the oldest ones until we have at most 12 – this stops the swipe shapes from becoming too long.
        if activeSlicePoints.count > 12 {
            activeSlicePoints.removeFirst(activeSlicePoints.count - 12)
        }
//
        //It needs to start its line at the position of the first swipe point, then go through each of the others drawing lines to each point.
        let path = UIBezierPath()
        path.move(to: activeSlicePoints[0])

        for i in 1..<activeSlicePoints.count {
            path.addLine(to: activeSlicePoints[i])
        }

        //Finally, it needs to update the slice shape paths so they get drawn using their designs – i.e., line width and color
        activeSliceFG.path = path.cgPath
        activeSliceBG.path = path.cgPath
    }
    
    func playSwooshSound(){
        isSwooshSoundActive = true
        
        let randomNumber = Int.random(in: 1...3)
        let soundName = "swoosh\(randomNumber).caf"
        
        let swooshSound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        
        run(swooshSound){
            [weak self] in
            self?.isSwooshSoundActive = false
        }
    }
    
    //Accept a parameter of whether we want to force a bomb, not force a bomb, or just be random.
    func createEnemy(forceBomb : ForceBomb = .random){
        let enemy : SKSpriteNode
        
        var enemyType = Int.random(in: 1...6)
        
        if forceBomb == .never{
            enemyType = 1
        } else if forceBomb == .always {
            enemyType = 0
        }
        
        //Decide whether to create a bomb or a penguin (based on the parameter input) then create the correct thing
        if enemyType == 0 {
            //TODO: bomb code goes here
            // 1. Create a new SKSpriteNode that will hold the fuse and the bomb image as children, setting its Z position to be 1.
            enemy = SKSpriteNode()
            enemy.zPosition = 1
            enemy.name = "bombContainer"
            
            // 2. Create the bomb image, name it "bomb", and add it to the container.
            let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
            bombImage.name = "bomb"
            enemy.addChild(bombImage)
         
            // 3. If the bomb fuse sound effect is playing, stop it and destroy it.
            if bombSoundEffect != nil {
                bombSoundEffect?.stop()
                bombSoundEffect = nil
            }
            
            // 4. Create a new bomb fuse sound effect, then play it.
            if let path = Bundle.main.url(forResource: "sliceBombFuse", withExtension: "caf"){
                if let sound = try? AVAudioPlayer(contentsOf: path){
                    bombSoundEffect = sound
                    sound.play()
                }
            }
            
            // 5. Create a particle emitter node, position it so that it's at the end of the bomb image's fuse, and add it to the container.
            if let emitter = SKEmitterNode(fileNamed: "sliceFuse"){
                emitter.position = CGPoint(x: 76, y: 64)
                enemy.addChild(emitter)
            }
        } else {
            enemy = SKSpriteNode(imageNamed: "penguin")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "enemy"
        }
        //TODO: position goes here
        
        //1. Give the enemy a random position off the bottom edge of the screen.
        let randomPosition = CGPoint(x: Int.random(in: 64...960), y: -128)
        enemy.position = randomPosition
        
        //2. Create a random angular velocity, which is how fast something should spin.
        let randomAngularVelocity = CGFloat.random(in: -3...3)
        let randomXVelocity : Int
        
        //3. Create a random X velocity (how far to move horizontally) that takes into account the enemy's position.
        if randomPosition.x < 256 {
            randomXVelocity = Int.random(in: 8...15)
        } else if randomPosition.x < 512 {
                randomXVelocity = Int.random(in: 3...5)
        } else if randomPosition.x < 768{
            randomXVelocity = -Int.random(in: 3...5)
        } else {
            randomXVelocity = -Int.random(in: 8...15)
        }
        
        //4. Create a random Y velocity just to make things fly at different speeds.
        let randomYVelocity = Int.random(in: 24...32)
        
        //5. Give all enemies a circular physics body where the collisionBitMask is set to 0 so they don't collide.
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64)
        enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * 40, dy: randomYVelocity * 40)
        enemy.physicsBody?.angularVelocity = randomAngularVelocity
        enemy.physicsBody?.collisionBitMask = 0
        
        
        //Add the new enemy to the scene, and also to our activeEnemies array.
        addChild(enemy)
        activeEnemies.append(enemy)
    }
    
    //do the specific logic to update the scence
    override func update(_ currentTime: TimeInterval) {
        var bombCount = 0
        
        for node in activeEnemies {
            if node.name == "bombContainer" {
                bombCount += 1
                break
            }
        }
        
        if bombCount == 0 {
            // no bomb - stop the sound
            bombSoundEffect?.stop()
            bombSoundEffect = nil
        }
    }
   
}
