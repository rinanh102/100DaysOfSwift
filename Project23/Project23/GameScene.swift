//
//  GameScene.swift
//  Project23
//
//  Created by henry on 13/05/2019.
//  Copyright © 2019 HenryNguyen. All rights reserved.
//

import SpriteKit


class GameScene: SKScene {
    
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
    
    //
    var isSwooshSoundActive = false
    
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
    
   
}
