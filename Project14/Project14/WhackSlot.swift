//
//  WhackSlot.swift
//  Project14
//
//  Created by henry on 03/04/2019.
//  Copyright © 2019 HenryNguyen. All rights reserved.
//
import SpriteKit
import UIKit

class WhackSlot: SKNode {
    var charNode : SKSpriteNode!  //penguin charecter
    
    var isVisible = false
    var isHit = false
    
    
    func configure(at position:  CGPoint){
        self.position = position
        
        let sprite = SKSpriteNode(imageNamed: "whackHole")
        addChild(sprite)
        
        let cropNode = SKCropNode()
        cropNode.position = CGPoint(x: 0, y: 15)
        cropNode.zPosition = 1
        cropNode.maskNode = SKSpriteNode(imageNamed: "whackMask")
        
        charNode = SKSpriteNode(imageNamed: "penguinGood")
        charNode.position = CGPoint(x: 0, y: -90)
        charNode.name = "character"
        cropNode.addChild(charNode)
        
        addChild(cropNode)
    }

    func show(hideTime: Double){
        //if the penguin is visible
        if isVisible { return }
        
        //TODO: show the penguin from underneath the hole
        charNode.run(SKAction.moveBy(x: 0, y: 80, duration: 0.05))
        isVisible = true
        isHit = false
        //TODO: use random number to show penguin; The Good one equal to one-third Evil one
        if Int.random(in: 0...2) == 0{
            charNode.texture = SKTexture(imageNamed: "penguinGood")
            charNode.name = "charFriend"
        } else {
            charNode.texture = SKTexture(imageNamed: "penguinEvil")
            charNode.name = "charEnemy"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + (hideTime * 3.5)){
            [weak self] in
            self?.hide()
        }
        
    }
    
    func hide(){
        if !isVisible { return }
        
        charNode.run(SKAction.moveBy(x: 0, y: -80, duration: 0.05))
        isVisible = false
    }
}
