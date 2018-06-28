 <img src="https://upload-images.jianshu.io/upload_images/3896436-13850b3081fef245.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/700">
 
 <img src="https://upload-images.jianshu.io/upload_images/3896436-f24ff8be3b6f9f33.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/700">
 
 <img src="https://upload-images.jianshu.io/upload_images/3896436-10ef8db5f7e412ae.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/700">
 

/*
 *  游戏中的所有元素全部由iFIERO所原创(除引用之外)，包括人物、音乐、场景等，
 *  创作的初衷就是让更多的游戏爱好者可以在开发游戏中获得自豪感 -- 让手机游戏开发变得简单。
 *  秉着开源分享的原则,iFIERO发布的游戏都尽可能的易懂实用，并开放所有源码，
 *  任何使用者都可以使用游戏中的代码块，也可以进行拷贝、修改、更新、升级，无须再经过iFIERO的同意。
 *  但这并不表示可以任意复制、拆分其中的游戏元素:
 *  用于[商业目的]而不注明出处，
 *  用于[任何教学]而不注明出处,
 *  用于[游戏上架]而不注明出处；
 *  另外,iFIERO有商用授权游戏元素，获得iFIERO官方授权后，即无任何限制！
 *  请尊重帮助过你的iFIERO的知识产权，非常感谢！
 *
 *  Created by VANGO杨 && ANDREW陈
 *  Copyright © 2018 iFiero. All rights reserved.
 *  www.iFIERO.com
 *  iFIERO -- 让手机游戏开发变得简单
 *

 *  SpaceBattle 宇宙大战 在此游戏中您将获得如下技能：
 *  1、LaunchScreen       学习如何设置游戏启动画面;
 *  2、Scenes             学习如何切换不同的场景 主菜单+游戏场景+游戏结束场景;
 *  3、Accleroation       利用重力加速度 让飞船左右移动;
 *  4、Endless Background 无限循环背景;
 *  5、Scene Edit         直接使用可见即所得操作;
 *  6、UserDefaults       保存游戏分数、最高分;
 *  7、Random             利用可复用的随机函数生成Enemy;
 *  8、Background Music   如何添加背景音乐;
 *  9、Particle           粒子爆炸特效;
 */
 
 
import SpriteKit
import GameplayKit
import CoreMotion

struct  PhysicsCategory {
    // static let BulletRed :UInt32 = 0x1 << 1 // Alien的子弹
    static let BulletBlue:UInt32 = 0x1 << 2
    static let Alien     :UInt32 = 0x1 << 3
    static let SpaceShip :UInt32 = 0x1 << 4
    static let None      :UInt32 = 0
}

class GameScene: SKScene,SKPhysicsContactDelegate {
    
    private var bgNode1:SKSpriteNode!
    private var bgNode2:SKSpriteNode!
    private var playerNode:SKSpriteNode!  // 玩家 宇宙飞船
    private var currentScore:SKLabelNode! // 当前分数节点
    private var cScore:Int = 0
    private var highScore:SKLabelNode!    // 最高分数
    private var hScore:Int = 0
    
    
    var lastUpdateTimeInterval:TimeInterval = 0
    var deltaTime:TimeInterval = 0
    let motionManager = CMMotionManager() // 重力加速度管理器
    var xAcceleration:CGFloat  = 0        // 存放x左右移动的加速度变量
    var yAcceleration:CGFloat  = 0
    
    
    override func didMove(to view: SKView) {
        // 建立物理世界 重力向下
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        // 碰撞接触代理
        physicsWorld.contactDelegate = self
        // 背景节点
        bgNode1 = childNode(withName: "BG1") as! SKSpriteNode
        bgNode2 = childNode(withName: "BG2") as! SKSpriteNode
        // 分数节点
        currentScore = childNode(withName: "currentScore") as! SKLabelNode
        highScore    = childNode(withName: "highScore")    as! SKLabelNode
        
        //表示第一次加载游戏
        if !UserDefaults.standard.bool(forKey: "HIGHSCORE") {
            UserDefaults.standard.set(0, forKey: "CURRENTSCORE")
            UserDefaults.standard.set(0, forKey: "HIGHSCORE")
        }
        // 表示重新游戏
        UserDefaults.standard.set(0, forKey: "CURRENTSCORE")      // 清空沙盒中保存的上一局的分数
        hScore = UserDefaults.standard.integer(forKey: "HIGHSCORE")    // 取出沙盒中的数字
        highScore.text = "HIGH:\(hScore)"
        
        // 背景音乐
        let bgMusic = SKAudioNode(fileNamed: "spaceBattle.mp3")
        bgMusic.autoplayLooped = true
        addChild(bgMusic)
        // 加入玩家飞船
        playerNode = childNode(withName: "SpaceShip") as! SKSpriteNode
        playerNode.physicsBody = SKPhysicsBody(circleOfRadius: self.playerNode.size.width / 2)
        playerNode.physicsBody?.affectedByGravity = false // 不受物理世界的重力影响
        playerNode.physicsBody?.isDynamic = true 
        playerNode.physicsBody?.categoryBitMask    = PhysicsCategory.SpaceShip
        playerNode.physicsBody?.contactTestBitMask = PhysicsCategory.Alien
        playerNode.physicsBody?.collisionBitMask   = PhysicsCategory.None
        
        /*
         * 手机加速度感应
         * 注意：加速度感应在模拟器Simulater无法感应，须用真机进行调试
         */
        motionManager.accelerometerUpdateInterval = 0.2 // 感应时间
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data, error) in
            //1. 取得data数据;
            guard let accelerometerData = data else {
                return
            }
            //2. 取得加速度
            let acceleration = accelerometerData.acceleration
            //3. 更新XAcceleration的值
            self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.5
            self.yAcceleration = CGFloat(acceleration.y) * 0.75 + self.yAcceleration * 0.5
            
        }
        // spawnAlien()
        Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(GameScene.spawnAlien), userInfo: nil, repeats: true)
        
        // Action 无限生成Alien
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // 每Frame的时间差
        if lastUpdateTimeInterval == 0 {
            lastUpdateTimeInterval = currentTime
        }
        deltaTime = currentTime - lastUpdateTimeInterval
        lastUpdateTimeInterval = currentTime
        
        // endless 无限循环星空背景
        updateBackground(deltaTime: deltaTime)
    }
    
    func  updateBackground(deltaTime:TimeInterval){
        // 下移
        bgNode1.position.y -= CGFloat(deltaTime * 300)
        bgNode2.position.y -= CGFloat(deltaTime * 300)
        // 第一个背景node
        if bgNode1.position.y  < -bgNode1.size.height {
            bgNode1.position.y = bgNode2.position.y + bgNode2.size.height
        }
        // 第二个背景node
        if bgNode2.position.y  < -bgNode2.size.height {
            bgNode2.position.y = bgNode1.position.y + bgNode1.size.height
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let _ = touch.location(in: self) // touchLocation
        // 播放torpedo发射音乐
        let actionFire = SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false)
        run(actionFire)
        
        spawnBulletAndFire() // 生成并发射子弹
        
    }
    // MARK: - 生成并发射子弹;
    func spawnBulletAndFire(){
        // 子弹
        let bulletNode = SKSpriteNode(imageNamed: "BulletBlue")
        bulletNode.position.x = playerNode.position.x
        // 子弹的Y轴位置 因为playNode的AnchorPoit位于飞船中心 所以子弹发射时的瞬间位置位于飞船正中心,要加上飞船的半径，位于枪口;
        bulletNode.position.y = playerNode.position.y + playerNode.size.height / 2
        bulletNode.zPosition = 1
        self.addChild(bulletNode)
        bulletNode.physicsBody = SKPhysicsBody(circleOfRadius: bulletNode.size.width / 2)
        bulletNode.physicsBody?.affectedByGravity = false // 子弹不受重力影响;
        bulletNode.physicsBody?.categoryBitMask   =  PhysicsCategory.BulletBlue
        bulletNode.physicsBody?.contactTestBitMask = PhysicsCategory.Alien
        bulletNode.physicsBody?.collisionBitMask = PhysicsCategory.None
        //子弹飞速运动，设置探测精细碰撞
        bulletNode.physicsBody?.usesPreciseCollisionDetection = true
        
        // 把子弹往上移出屏幕
        let moveTo = CGPoint(x: playerNode.position.x, y: playerNode.position.y + self.frame.size.height)
        // bulletNode.run(SKAction.move(to:moveTo, duration: TimeInterval(0.5)))
        /*
         * 粒子效果
         * 1.新建一个SKNODE => trailNode
         * 2.新建粒子效果SKEmitterNode,设置tragetNode = trailNode
         * 3.子弹加上emitterNode
         */
        let trailNode = SKNode()
        trailNode.zPosition = 1
        trailNode.name = "trail"
        addChild(trailNode)
        
        let emitterNode = SKEmitterNode(fileNamed: "ShootTrailBlue")! // particles文件夹存放粒子效果
        emitterNode.targetNode = trailNode  // 设置粒子效果的目标为trailNode => 跟随新建的trailNode
        bulletNode.addChild(emitterNode)    // 在子弹节点Node加上粒子效果;
        
        bulletNode.run(SKAction.sequence([
            SKAction.move(to: moveTo, duration: TimeInterval(0.5)),
            SKAction.run({
                bulletNode.removeFromParent() // 移除 子弹bulltedNode
                trailNode.removeFromParent()  // 移除 trailNode
            })]))
    }
    // 生成随机Alien
    @objc func spawnAlien() {
        // 1 or 2
        let i = Int(CGFloat(arc4random()).truncatingRemainder(dividingBy: 2) + 1)
        
        let imageName = "Enemy0\(i)"
        let alien  = SKSpriteNode(imageNamed: imageName)
        alien.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        alien.zPosition   = 1
        alien.name = "Alien"
        var xPosition:CGFloat = 0.0
        // 生成随机的x-Axis轴的位置
        xPosition = CGFloat.random(min: -self.frame.size.width+alien.size.width, max: self.frame.size.width - alien.size.width)
        alien.position = CGPoint(x: xPosition, y: self.frame.size.height + alien.size.height * 2)
        self.addChild(alien)
        // 物理世界 PhysicsWorld
        // 1.设置物理身体
        alien.physicsBody = SKPhysicsBody(circleOfRadius: alien.size.width / 2)
        // 不受重力影响，自定义飞船移动速度;
        alien.physicsBody?.affectedByGravity = false
        // 2.设置唯一属性
        alien.physicsBody?.categoryBitMask   = PhysicsCategory.Alien
        // 3.和哪些节点Node会发生碰撞
        alien.physicsBody?.contactTestBitMask = PhysicsCategory.BulletBlue | PhysicsCategory.SpaceShip
        alien.physicsBody?.collisionBitMask   = PhysicsCategory.None
        
        let duration = CGFloat.random(min: CGFloat(1.0), max: CGFloat(3.8))
        let actionDown = SKAction.move(to: CGPoint(x: xPosition, y: -self.frame.size.height), duration: TimeInterval(duration))
        alien.run(SKAction.sequence([actionDown,
                                     SKAction.run({
                                        alien.removeFromParent() // 移除节点;
                                     })]))
        
    }
    // 手机重力感应
    override func didSimulatePhysics() {
        // 取得xAcceleration的位置并进行更新
        self.playerNode.position.x += self.xAcceleration * 50
        self.playerNode.position.y += self.yAcceleration * 50
        // 让player => SpaceShip在屏幕之间滑动 x
        // X-Axis X轴水平方向 最小值
        // 如果player的x-axis最小值 < player飞船的size.with 1/2 设飞船的最小值为 size.with/2
        if self.playerNode.position.x <  -self.frame.size.width / 2 + self.playerNode.size.width {
            self.playerNode.position.x =  -self.frame.size.width / 2 + self.playerNode.size.width
        }
        // 最大值
        if self.playerNode.position.x >   self.frame.size.width / 2 - self.playerNode.size.width {
            self.playerNode.position.x =  self.frame.size.width / 2 - self.playerNode.size.width
        }
        // Y-Axis Y轴方向
        if self.playerNode.position.y  > -self.playerNode.size.height {
            self.playerNode.position.y =  -self.playerNode.size.height
        }
        
        if self.playerNode.position.y <  -self.frame.size.height / 2 + self.playerNode.size.height {
            self.playerNode.position.y = -self.frame.size.height / 2 + self.playerNode.size.height
        }
    }
    
    //MARK:- 发生碰撞
    func didBegin(_ contact: SKPhysicsContact) {
        
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch contactMask {
        // 子弹vs外星人
        case PhysicsCategory.Alien | PhysicsCategory.BulletBlue:
            bulletHitAlien(nodeA: contact.bodyA.node as! SKSpriteNode,nodeB: contact.bodyB.node as! SKSpriteNode)
        // 外星人Alien撞击到飞船
        case PhysicsCategory.Alien | PhysicsCategory.SpaceShip:
            alienHitSpaceShip(nodeA: contact.bodyA.node as! SKSpriteNode, nodeB: contact.bodyB.node as! SKSpriteNode)
            
        default:
            break
        }
    }
    // MARK: 子弹vs外星人
    func bulletHitAlien(nodeA:SKSpriteNode,nodeB:SKSpriteNode){
        
        // 击中粒子效果 Particle
        let explosion = SKEmitterNode(fileNamed: "ExplosionBlue")!
        explosion.position = nodeA.position // 或者 nodeB.position
        self.addChild(explosion)
        
        explosion.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.3),
            SKAction.run {
                explosion.removeFromParent()
            }]))
        // 击中的音乐
        let actionColision = SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false)
        run(actionColision)
        
        // 分数统计
        cScore += 1
        currentScore.text = "SCORE:\(cScore)"
        // 保存当前分数
        UserDefaults.standard.set(cScore, forKey: "CURRENTSCORE")
        
        if cScore > hScore {
            hScore = cScore
            highScore.text = "High:\(hScore)"
            // 保存最高分数
            UserDefaults.standard.set(cScore, forKey: "HIGHSCORE")
        }
        // 判断哪个是子弹节点bulletNode,碰撞didBegin没有比较大小时，则会相互切换，也就是A和B互相切换;
        if nodeA.physicsBody?.categoryBitMask == PhysicsCategory.BulletBlue {
            nodeA.removeAllChildren() // 移除所有子效果 emitter
            nodeA.isHidden = true     // 子弹隐藏
            nodeA.physicsBody?.categoryBitMask = 0 // 设置子弹不会再发生碰撞
            nodeB.removeFromParent()  // 移除外星人
        }else if nodeB.physicsBody?.categoryBitMask == PhysicsCategory.BulletBlue {
            nodeA.removeFromParent()  // 移除外星人
            nodeB.removeAllChildren()
            nodeB.isHidden =  true
            nodeB.physicsBody?.categoryBitMask = 0
        }
    }
    
    // MARK: 外星人Alien撞击到飞船
    func alienHitSpaceShip(nodeA:SKSpriteNode,nodeB:SKSpriteNode){
        
        if (nodeA.physicsBody?.categoryBitMask == PhysicsCategory.Alien  || nodeB.physicsBody?.categoryBitMask == PhysicsCategory.Alien) && (nodeA.physicsBody?.categoryBitMask == PhysicsCategory.SpaceShip || nodeB.physicsBody?.categoryBitMask == PhysicsCategory.SpaceShip) {
            // print("撞击到飞船")
            // 击中粒子效果 Particle
            let explosion = SKEmitterNode(fileNamed: "Explosion")!
            explosion.position = nodeA.position
            self.addChild(explosion)
            nodeA.removeFromParent()
            nodeB.removeFromParent()
            // 播放失败音乐 + 切换到结束游戏
            let loseMusicAction = SKAction.playSoundFileNamed("", waitForCompletion: false)
            self.run(SKAction.sequence([
                loseMusicAction,
                SKAction.wait(forDuration: TimeInterval(0.7)),
                SKAction.run {
                    // 切换游戏结束场景
                    let reveal = SKTransition.doorsOpenHorizontal(withDuration: TimeInterval(0.5))
                    let loseScene = LoseScene(fileNamed: "LoseScene")
                    loseScene?.size = self.size
                    loseScene?.scaleMode = .aspectFill
                    self.view?.presentScene(loseScene!, transition: reveal)
                }]))
            
        }
        
    }
}

视频讲解：宇宙大战 SPACE BATTLE (一) SpriteKit游戏视频教程 http://www.ifiero.com/index.php/archives/spacebattlespritekitvideogametutorial
