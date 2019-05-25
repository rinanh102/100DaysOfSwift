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
    
    // CaseIterable. This is one of Swift’s most useful protocols, and it will automatically add an allCases property to the SequenceType enum that lists all its cases as an array. This is really useful in our project because we can then use randomElement() to pick random sequence types to run our game.
    enum SequenceType : CaseIterable{
        case oneNoBomb, one, twoWithOneBomb, two, three, four, chain, fastChain, fastMoving
    }
    // a new enum that tracks what kind of enemy should be created: should we force a bomb always, should we force a bomb never, or use the default randomization?
    enum ForceBomb{
        case never, always, random
    }
    
    var gameScore : SKLabelNode!
    var someThing : SKLabelNode!
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
    
    //TODO: properties for sequence
    var popupTime = 0.9  // the amount of time to wait between the last enemy being destroyed and a new one being created
    var sequence = [SequenceType]() // an array of our SequenceType enum that defines what enemies to create.
    var sequencePosition = 0 // is where we are right now in the game
    var chainDelay = 3.0
    var nextSequenceQueued = true // is used so we know when all the enemies are destroyed and we're ready to create more.

    var isGameEnd = false
    //MARK: CHALLENGE 1: Properties
    var screenWidth : CGFloat = 1024.0
    var randomLowVelocity : Int {
        return Int.random(in: 3...5)
    }
    var randomHighVelocity : Int {
        return Int.random(in: 8...15)
    }
    
    //MARK: challenge 2 Properties
    var isFast = false
    
    //MARK: Challenge 3 Properties
    var gameOver : SKLabelNode!
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.zPosition = -1
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        addChild(background)
        
        //The default gravity of our physics world is -0.98, which is roughly equivalent to Earth's gravity. I'm using a slightly lower value so that items stay up in the air a bit longer.
        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        physicsWorld.speed = 0.85
//        createGameOver()
        createScore()
        createLives()
        createSlices()
        
        
        sequence = [ .oneNoBomb, .one, .twoWithOneBomb, .twoWithOneBomb, .three , .one, .chain, .fastMoving]
        
        for _ in 0...1000 {
            if let nextSequence = SequenceType.allCases.randomElement() {
                sequence.append(nextSequence)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in self?.tossEnemies()}
    }
   
    func createScore(){
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        gameScore.position = CGPoint(x: 10, y: 10)
        score = 0
        
       
    }
    func createGameOver(){
        gameOver = SKLabelNode(fontNamed: "Chalkduster")
        gameOver.text = "Game Over"
        gameOver.position = CGPoint(x: 512, y: 384)
        gameOver.horizontalAlignmentMode = .center
        gameOver.fontSize = 100
        gameOver.zPosition = 2
        addChild(gameOver)
        print("gameover")
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
        if isGameEnd { return }
        
        // figure out where user touched
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        // add to the array
        activeSlicePoints.append(location)
        redrawActiveSlice()
        
        if !isSwooshSoundActive {
            playSwooshSound()
        }
        
        //
        let nodeAtPoint = nodes(at: location)
        
        for case let node as SKSpriteNode in nodeAtPoint {
            if node.name == "enemy" {
                //TODO: destroy penguin
                
                // 1. Create a particle effect over the penguin.
                if let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy") {
                    emitter.position = node.position
                    addChild(emitter)
                }
                
                // 2. Clear its node name so that it can't be swiped repeatedly.
                node.name = ""
                
                // 3. Disable the isDynamic of its physics body so that it doesn't carry on falling.
                node.physicsBody?.isDynamic = false
                
                // 4. Make the penguin scale out and fade out at the same time.
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                
                // 5. After making the penguin scale out and fade out, we should remove it from the scene.
                let seq = SKAction.sequence([group, .removeFromParent()])
                node.run(seq)
                
                //6. Add one to the player's score.
                // Challenge 2: double score
                if isFast {
                    score += 2
                    isFast = false
                    print("DOUBLE SCORE!============")
                } else {
                    score += 1
                }
                
                // 7. Remove the enemy from our activeEnemies array.
                if let index = activeEnemies.firstIndex(of: node) {
                    activeEnemies.remove(at: index)
                }
                
                // 8. Play a sound so the player knows they hit the penguin.
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
                
            } else if node.name == "bomb" {
                //TODO: destroy bomb
                guard let bombContainer = node.parent as? SKSpriteNode else { continue }
                if let emitter = SKEmitterNode(fileNamed: "sliceHitBomb") {
                    emitter.position = bombContainer.position
                    addChild(emitter)
                }
                
                node.name = ""
                bombContainer.physicsBody?.isDynamic = false
                
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                
                let seq = SKAction.sequence([group, .removeFromParent()])
                bombContainer.run(seq)
                
                if let index = activeEnemies.firstIndex(of: bombContainer) {
                    activeEnemies.remove(at: index)
                }
                
                run(SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false))
                endGame(triggeredByBomb: true)
                
            }
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
    //MARK: Challenge 2
    // Challenge 2: Add a parameter speedType to control the fast-moving type
    func createEnemy(forceBomb : ForceBomb = .random, speedType : Int = 1){
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
        if randomPosition.x < screenWidth * 0.25 {
            randomXVelocity = randomHighVelocity * speedType
        } else if randomPosition.x < screenWidth * 0.5 {
                randomXVelocity = randomLowVelocity * speedType
        } else if randomPosition.x < screenWidth * 0.75 {
            randomXVelocity = -randomLowVelocity * speedType
        } else {
            randomXVelocity = -randomHighVelocity * speedType
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
    
    func tossEnemies(){
        if isGameEnd { return }

        popupTime *= 0.991
        chainDelay *= 0.99
        physicsWorld.speed *= 1.02
        
        let sequenceType = sequence[sequencePosition]
        
        switch sequenceType {
        case .oneNoBomb:
            createEnemy(forceBomb: .never)
            
        case .one:
            createEnemy()
            
        case .twoWithOneBomb:
            createEnemy(forceBomb: .never)
            createEnemy(forceBomb: .always)
        
        case .two:
            createEnemy()
            createEnemy()
        
        case .three:
            createEnemy()
            createEnemy()
            createEnemy()
            
        case .four:
            createEnemy()
            createEnemy()
            createEnemy()
            createEnemy()
            
        case .chain:
            createEnemy()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0)){ [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 2)){ [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 3)){ [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 4)){ [weak self] in self?.createEnemy() }
            
        case .fastChain:
            createEnemy()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0)){ [weak self] in self?.createEnemy()}
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 2)){ [weak self] in self?.createEnemy()}
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 3)){ [weak self] in self?.createEnemy()}
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 4)){ [weak self] in self?.createEnemy()}
          
        // Challenge 2: increase speed double
        case .fastMoving:
            createEnemy(speedType: 2)
            isFast = true
            print("FAST!---------------------")
            
        }
        sequencePosition += 1
        //  If it's false, it means we don't have a call to tossEnemies() in the pipeline waiting to execute. It gets set to true only in the gap between the previous sequence item finishing and tossEnemies() being called.
        nextSequenceQueued = false
    }
    
    //do the specific logic to update the scence
    override func update(_ currentTime: TimeInterval) {
        
        if activeEnemies.count > 0 {
            for (index, node) in activeEnemies.enumerated().reversed() {
                if node.position.y < -140 {
                    node.removeAllActions()
                    
                    if node.name == "enemy" {
                        node.name = ""
                        subtractLife()
                        
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    } else if node.name == "bombContainer" {
                        node.name = ""
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    }
                    
                }
            }
        } else {
            //If we don't have any active enemies and we haven't already queued the next enemy sequence, we schedule the next enemy sequence and set nextSequenceQueued to be true
            if !nextSequenceQueued {
                DispatchQueue.main.asyncAfter(deadline: .now() + popupTime) { [weak self] in self?.tossEnemies()}
                
                nextSequenceQueued = true
            }
        }
        
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
   
    func endGame(triggeredByBomb: Bool) {
        
        if isGameEnd {
            return
        }
        
        isGameEnd = true
        physicsWorld.speed = 0
        isUserInteractionEnabled = false
        createGameOver()
       
        
        bombSoundEffect?.stop()
        bombSoundEffect = nil
        
        if triggeredByBomb {
            livesImage[0].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImage[1].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImage[2].texture = SKTexture(imageNamed: "sliceLifeGone")
        }
    }
    
    func subtractLife(){
        lives -= 1
        
        run(SKAction.playSoundFileNamed("wrong.caf", waitForCompletion: false))
        
        var life: SKSpriteNode
        
        if lives == 2 {
            life = livesImage[0]
        } else if lives == 1 {
            life = livesImage[1]
        } else {
            life = livesImage[2]
            endGame(triggeredByBomb: false)
        }
        
        // using SKTexture to modify the contents of a sprite node without having to recreate it, just like in project 14.
        life.texture = SKTexture(imageNamed: "sliceLifeGone")
        
        life.xScale = 1.3
        life.yScale = 1.3
        life.run(SKAction.scale(to: 1, duration: 0.1))
    }
    
   
}
