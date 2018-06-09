//
//  LoseScene.swift
//  SpaceBattle
//
//  Created by apiapia on 4/11/18.
//  Copyright © 2018 iFiero. All rights reserved.
//

import SpriteKit

class LoseScene:SKScene {
    private var play :SKSpriteNode!
    
    private var currentScore:SKLabelNode! // 当局分数
    private var highScore:SKLabelNode!    // 最高分数
    
    override func didMove(to view: SKView) {
        // 找到 名称为Play的节点
        play = childNode(withName: "Play") as! SKSpriteNode
        currentScore = childNode(withName: "currentScore") as! SKLabelNode
        highScore    = childNode(withName: "highScore")    as! SKLabelNode
        currentScore.text = "SCORE:\(UserDefaults.standard.integer(forKey: "CURRENTSCORE"))"   // 取出当前分数
        highScore.text    = "HIGH SCORE:\(UserDefaults.standard.integer(forKey: "HIGHSCORE"))" // 取出沙盒中的最高分数
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        // 获得点击位置在Play节点Node
        if play.contains(touchLocation) {
            let reveal = SKTransition.doorsOpenVertical(withDuration: TimeInterval(0.5))
            let scene = GameScene(fileNamed: "GameScene")
            scene?.size = self.size
            scene?.scaleMode = .aspectFill
            self.view?.presentScene(scene!, transition: reveal)
        }
    }
    
}

