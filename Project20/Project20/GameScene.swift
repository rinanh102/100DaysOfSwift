//
//  GameScene.swift
//  Project20
//
//  Created by henry on 29/04/2019.
//  Copyright © 2019 HenryNguyen. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    //l use this to call the launchFireworks() method every six seconds.
    var gameTimer : Timer?
    //will be a container node with other nodes inside them
    var fireworks = [SKNode]()
    
    //define where we launch fireworks from. Each of them will be just off screen to one side.
    let leftEdge = -22
    let bottomEdge = -22
    let rightEdge = 1024 + 22
    
    var scoreLabel : SKLabelNode!
    
    // track the player's score
    var score = 0 {
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    var numberOfLanuch = 0

    
    override func didMove(to view: SKView) {
        //TODO: put the background picture
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.position = CGPoint(x: 10, y: 10)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.fontSize = 48
        scoreLabel.zPosition = 1
        addChild(scoreLabel)
        
        
        //TODO: start up Timer
        // timer carry on till we call it to stop
        startTimer()
      
        
    }
    
    @objc func launchFireworks(){
        //TODO: four types of firework spreads
//        if numberOfLanuch < 10 {
            let movementAmount: CGFloat = 1800
            numberOfLanuch += 1
            switch Int.random(in: 0...3) {
            case 0:
                // Straight up
                createFirework(xMovement: 0, x: 512, y: bottomEdge)
                createFirework(xMovement: 0, x: 512 - 100, y: bottomEdge)
                createFirework(xMovement: 0, x: 512 - 200, y: bottomEdge)
                createFirework(xMovement: 0, x: 512 + 100, y: bottomEdge)
                createFirework(xMovement: 0, x: 512 + 200, y: bottomEdge)
            case 1:
                // in a fan
                createFirework(xMovement: 0, x: 512, y: bottomEdge)
                createFirework(xMovement: 200, x: 512 + 200, y: bottomEdge)
                createFirework(xMovement: 100, x: 512 + 100, y: bottomEdge)
                createFirework(xMovement: -100, x: 512 - 100, y: bottomEdge)
                createFirework(xMovement: -200, x: 512 - 200, y: bottomEdge)
            case 2:
                //left to right
                createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
                createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
                createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
                createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
                createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge)
            case 3:
                // right to left
                createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
                createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
                createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
                createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
                createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)
                
            default:
                break
        
        }
        //Challenge 2
        if numberOfLanuch < 10 {
            startTimer()
        }
        
    }
    
    //MARK: xMovement: speed of firework, x&y: position for creation
    
    func createFirework(xMovement: CGFloat, x: Int, y: Int){ // xMovement : the X range of movement of the firework
        //TODO: create an SKNode: act as firework container
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        //TODO: create rocket sprite node, name "firework", add to container
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.colorBlendFactor = 1 //with colorBlendFactor set to 1 (use the new color exclusively)
        firework.name = "firework"
        node.addChild(firework)
        
        //TODO: give the firework spriteNode 1 of 3 random colors
        switch Int.random(in: 0...2) {
        case 0:
            firework.color = .red
        case 1:
            firework.color = .cyan
        case 2:
            firework.color = . green
        default:
            break
        }
        
        //TODO: Create a UIBezierPath that will represent the movement of the firework.
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000))
        
        //TODO: Tell the container node to follow that path, turning itself as needed.
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        // add the action to the list that node will execute
        node.run(move)
        //TODO: Create particles behind the rocket to make it look like the fireworks are lit.
        if let emitter = SKEmitterNode(fileNamed: "fuse"){
            emitter.position = CGPoint(x: 0, y: -22)
            node.addChild(emitter)
        }
        //TODO: Add the firework to our fireworks array and also to the scene.
        fireworks.append(node)
        addChild(node)
        
    }
    // we want to run the body of our loop only for sprite nodes, not for the other items
    func checkTouches(_ touches: Set<UITouch>){
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        for case let node as SKSpriteNode in nodesAtPoint{
            guard node.name == "firework" else { continue }
            
            //parent is the container node: holds the firework image and its spark emitter
            for parent in fireworks{
                guard let firework = parent.children.first as? SKSpriteNode else { continue }
                // If the firework was selected and is a different color to the firework that was just tapped, then put it back
                if firework.name == "selected" && firework.color != node.color{
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
            }
            node.name = "selected"
            node.colorBlendFactor = 0
        }
    }
    
    //TODO: send the infomation to checkTouches() method
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        checkTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches)
    }
    
    override func update(_ currentTime: TimeInterval) {
        //  When removing items, we're going to loop through the array backwards rather than forwards.
        for (index, firework) in fireworks.enumerated().reversed() {
            if firework.position.y > 900 {
                fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
    
    //MARK: Explode the single firework
    //  it creates an explosion where the firework was, then removes the firework from the game scene.
    func explode(firework: SKNode){
        guard let emitter = SKEmitterNode(fileNamed: "explode") else { return }
            emitter.position = firework.position
            addChild(emitter)
        
        firework.removeFromParent()
        
        // Challenge 3: Use the waitForDuration and removeFromParent actions in a sequence to make sure explosion particle emitters are removed from the game scene when they are finished.
        let remove = SKAction.run {
            emitter.removeFromParent()
        }
        
        emitter.run(SKAction.sequence([SKAction.wait(forDuration: 2), remove]))
        
    }
    
    //
    func explodeFireworks(){
        var numExploded = 0
        
        for (index, fireworkContainer) in fireworks.enumerated().reversed() {
            guard let firework = fireworkContainer.children.first as? SKSpriteNode else { continue }
            
            if firework.name == "selectted" {
                //destroy this firework!
                explode(firework: fireworkContainer)
                fireworks.remove(at: index)
                numExploded += 1
            }
        }
        
        switch numExploded {
        case 0:
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        default:
            score += 4000
        }
    }
    
    //Challenge 2
    func startTimer(){
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: false)
    }
}
