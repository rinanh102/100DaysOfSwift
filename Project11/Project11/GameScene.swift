//
//  GameScene.swift
//  Project11
//
//  Created by henry on 20/03/2019.
//  Copyright © 2019 HenryNguyen. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
  
    var scoreLabel : SKLabelNode!
    var  score = 0{
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var editLabel : SKLabelNode!
    var editingMode : Bool = false{
        didSet{
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    var gameOverLabel : SKLabelNode!
    var newGameLabel : SKLabelNode!
    var numberBallLabel : SKLabelNode!
    var numberBall = 5{
        didSet{
            numberBallLabel.text = "Ball: \(numberBall)/5"
        }
    }
    
    var colorBall = ["ballYellow", "ballRed", "ballPurple", "ballGrey", "ballBlue", "ballGreen", "ballCyan"]
//    var box = SKSpriteNode?.self
    
    override func didMove(to view: SKView) {
    let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)

        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)

        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)

        numberBallLabel = SKLabelNode(fontNamed: "Chalkduster")
        numberBallLabel.text = "Ball: 5/5"
        numberBallLabel.position = CGPoint(x: 500, y: 700)
        addChild(numberBallLabel)
        
        gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel.text = "Game Over"
        gameOverLabel.position = CGPoint(x: 512, y: 400)
        
        newGameLabel = SKLabelNode(fontNamed: "Chalkduster")
        newGameLabel.text = "New Game"
        newGameLabel.position = CGPoint(x: 512, y: 300)
       
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            let location = touch.location(in: self)
            
            let objects = nodes(at: location)
            
            if objects.contains(editLabel){
                editingMode.toggle()
            } else if objects.contains(newGameLabel){
                score = 0
                numberBall = 5
                newGameLabel.removeFromParent()
                gameOverLabel.removeFromParent()
                
            } else {
                if editingMode{
                    //TODO: Create box
                    let size = CGSize(width: Int.random(in: 16...128), height: 16)
                    let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                    box.zRotation = CGFloat.random(in: 0...3)
                    box.position = location
                    box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                    box.physicsBody?.isDynamic = false
                    box.name = "box"
                    addChild(box)
                    
                } else {
                    //TODO: Create ball
                    if numberBall > 0{
                        colorBall.shuffle()
                        let ball = SKSpriteNode(imageNamed: colorBall[0])
                        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
                        ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
                        ball.physicsBody?.restitution = 0.4
                        ball.position = CGPoint(x: location.x, y: 700)
                        ball.name = "ball"
                        addChild(ball)
                    }
                }
            }
        }
    }
    //MARK:
    func makeBouncer(at position: CGPoint){
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    //MARK: Make the slots at the bottom
    func makeSlot(at position: CGPoint, isGood : Bool){
        let slotBase : SKSpriteNode
        let slotGlow : SKSpriteNode
        if isGood{
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    //MARK:
    func collisionBetween(ball: SKNode, object: SKNode){
        if object.name == "good"{
            destroy(object_A: ball, object_B: object)
            score += 1
//            numberBall += 1
        } else if object.name == "bad"{
            destroy(object_A: ball, object_B: object)
            score -= 1
            numberBall -= 1
        } else if object.name == "box"{
            destroy(object_A: object, object_B: ball)
        }
        if numberBall == 0 {
            addChild(gameOverLabel)
            addChild(newGameLabel)
        }
    }
    
    
    func destroy(object_A: SKNode, object_B: SKNode){
        guard let fireParticles = SKEmitterNode(fileNamed: "FireParticles") else { return }
        guard let whiteParticles = SKEmitterNode(fileNamed: "FireParticles2") else { return }
        
        if object_A.name == "box" || object_B.name == "bad"{
            fireParticles.position = object_A.position
            addChild(fireParticles)
        } else if object_B.name == "good"{
            whiteParticles.position = object_A.position
            addChild(whiteParticles)
        }
        object_A.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let bodyA = contact.bodyA.node else { return }
        guard let bodyB = contact.bodyB.node else { return }
        
        if bodyA.name == "ball" {
            collisionBetween(ball: bodyA, object: bodyB)
        } else if bodyB.name == "ball" {
            collisionBetween(ball: bodyB, object: bodyA)
        }
    }

}
