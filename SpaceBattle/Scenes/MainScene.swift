//
//  MainScene.swift
//  SpaceBattle
//
//  Copyright © 2018 iFiero. All rights reserved.
//

import SpriteKit

class MainScene:SKScene {
    
    private var play:SKSpriteNode!
    
    override func didMove(to view: SKView) {
        
        play = childNode(withName: "Play") as! SKSpriteNode
        // 背景音乐
        let bgMusic = SKAudioNode(fileNamed: "spaceBattle.mp3")
        bgMusic.autoplayLooped = true
        addChild(bgMusic)
     
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard  let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        if  play.contains(touchLocation) {
            // 进入游戏
            print("进入")
            let reveal = SKTransition.doorsOpenVertical(withDuration: TimeInterval(0.5))
            let mainScene = GameScene(fileNamed: "GameScene")
            mainScene?.size = self.size
            mainScene?.scaleMode = .aspectFill
            self.view?.presentScene(mainScene!, transition: reveal)
            
        }
    }
}
