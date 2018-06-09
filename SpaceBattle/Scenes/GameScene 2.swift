//
//  GameScene.swift
//  SpaceBattle
//  GameState + Accleroation + Endless Background + Scene Edit
//  Created by apiapia on 3/31/18.
//  Copyright © 2018 iFiero. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
     
    var lastUpdateTimeInterval:TimeInterval = 0
    var deltaTime:TimeInterval = 0
    
    let background1Node = SKSpriteNode(imageNamed: "BG_SpaceBattle_planet")
    let background2Node = SKSpriteNode(imageNamed: "BG_SpaceBattle_planet")
    
    override func didMove(to view: SKView) {
        
 
        background1Node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        background1Node.position = CGPoint.zero
        background1Node.name = "bg"
        self.addChild(background1Node)
        
      
  
        background2Node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        background2Node.position = CGPoint(x: 0, y: self.frame.height * 1)
        background2Node.name = "bg"
        self.addChild(background2Node)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // 每Frame的时间差
        if lastUpdateTimeInterval == 0 {
            lastUpdateTimeInterval = currentTime
        }
        deltaTime = currentTime - lastUpdateTimeInterval
        lastUpdateTimeInterval = currentTime
        
        // 更新星空背景
        updateBackground(deltaTime: deltaTime)
    }
    
    func  updateBackground(deltaTime:TimeInterval){
        
        background1Node.position.y -= 5
        background2Node.position.y -= 5
        
        if background1Node.position.y < -background1Node.size.height {
            background1Node.position.y = background2Node.position.y + background2Node.size.height
        }
        if background2Node.position.y < -background2Node.size.height {
            background2Node.position.y = background1Node.position.y + background1Node.size.height
        }
        
    }
}
