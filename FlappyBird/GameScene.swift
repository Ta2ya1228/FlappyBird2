//
//  GameScene.swift
//  FlappyBird
//
//  Created by 後達哉 on 2018/03/03.
//  Copyright © 2018年 Ta2ya1228. All rights reserved.
//

//クラス(SKScene, SKPhysicsContactDelegate)を輸入
import SpriteKit


//SKSceneのゲームシーンのためのクラス(ノードなどが入る)
//クラス(SKPhysics)継承を増やすと使えるメソッド(物理演算)増える
class GameScene: SKScene, SKPhysicsContactDelegate {

    //GameSceneで直接使うNodeはこの３つ！
    var scrollNode:SKNode!   //あとで、色んなスプライトの箱になる
    var wallNode:SKNode!     //scrollだけでなく、生成があるから
    var bird:SKSpriteNode!
    var scoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    var gameOverLabelNode:SKLabelNode!
    var scoreNode:SKNode!

    
    
    //衝突判定カテゴリー
    let birdCategory: UInt32 = 1 << 0       //0...00001         32桁の中でどこに1があるかで物体を判断する。
    let groundCategory: UInt32 = 1 << 1     //0...00010         x << y は 「xという数字をy桁目に入れる」という意味
    let wallCategory: UInt32 = 1 << 2       //0...0010
    let scoreCategory: UInt32 = 1 << 3      //0...0100
    
    //スコア用
    var score = 0
    let userDefaults:UserDefaults = UserDefaults.standard
    
    
    

    //画面をタップした時に呼ばれる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {if scrollNode.speed > 0{
        //鳥の速度をゼロにする
        bird.physicsBody?.velocity = CGVector.zero
        
        //鳥に縦方向の力を与える
        bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
    }else if bird.speed == 0{
        restart()
        }
    }
    
    
    

    
    //SKView上にシーン(ゲーム画面)が表示されたときに呼ばれるメソッド
    override func didMove(to view: SKView) {
        
        //重力を設定(Sceneに)
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -4.0)
        physicsWorld.contactDelegate = self
        
        
        //背景色を設定
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue:0.90, alpha: 1)
        
        //スクロールするスプライトをまとめる箱(ゲームオーバーなった時一括でスクロール止めるために)
        scrollNode = SKNode()   //これ自体は画面に表示しないからSpriteNodeではない
        addChild(scrollNode)
        
        
        wallNode = SKNode()       //生成する！
        scrollNode.addChild(wallNode)  //生んでスライドするだけ
        
        scoreNode = SKNode()
        scrollNode.addChild(scoreNode)
        //各種スプライトノード(処理軽いのに高速で画像を描画する)を生成する処理をメソッドに分割
        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        setupScoreLabel()
        setupScore()
    }
    
    
    func setupGround(){
        //地面の画像を読み込む
        let groundTexture = SKTexture(imageNamed: "ground")
        
        //画像が多少荒くなっても処理速度は落とさない
        groundTexture.filteringMode = .nearest
        
        //必要な枚数を計算
        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2
        
    //スクロールするアクションを作成
        //左方向に画像一枚分スクロールさせるアクション
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width, y:0, duration: 5.0)
        
        //元の位置に戻すアクション
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y:0, duration: 0.0)
        
        //左にスクロール->元の位置->左にスクロールと無限に繰り替えるアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))
        
        //groundのスプライト(画像)を配置する
        for i in 0..<needNumber{
            let sprite = SKSpriteNode(texture: groundTexture)
            
            //スプライトの表示する位置を指定する
            sprite.position = CGPoint(
                x: groundTexture.size().width * (CGFloat(i) + 0.5),
                y: groundTexture.size().height * 0.5
            )
            
            //スプライトにアクションを設定する
            sprite.run(repeatScrollGround)
            
            // スプライトに物理演算を設定する
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
            
            // 衝突のカテゴリー設定
            sprite.physicsBody?.categoryBitMask = groundCategory
            
            // 衝突の時に動かないように設定する
            sprite.physicsBody?.isDynamic = false

            //スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    
    //アクション + ノード = sprite(定数) を作って、scrollNode(didMoveで起動)に入れる
    func setupCloud(){
        //雲の画像を読み込む
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = .nearest
        
        // 必要な枚数を計算
        let needCloudNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2
        
        // スクロールするアクションを作成
        // 左方向に画像一枚分スクロールさせるアクション
        let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width , y: 0, duration: 20.0)
        
        // 元の位置に戻すアクション
        let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0.0)
        
        // (アクション完成)左にスクロール->元の位置->左にスクロールと無限に繰り替えるアクション
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))
        
        
        
        // スプライトを配置する
        for i in 0..<needCloudNumber {
            let sprite = SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100 // 一番後ろになるようにする
            
            // スプライトの表示する位置を指定する
            sprite.position = CGPoint(
                x: cloudTexture.size().width * (CGFloat(i) + 0.5),
                y: self.size.height - cloudTexture.size().height * 0.5
            )
            
            // スプライトにアニメーション(さっき完成させた)を設定する
            sprite.run(repeatScrollCloud)
            
            // スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    
    
    
    func setupWall(){
        //壁の画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .linear  //当たり判定のために画質優先
        
        //移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
        
        //画面外まで移動するアクションを作成
        let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration: 4.0)
        
        //自身を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()
        
        //２つのアニメーションを順に実行するアクション(sequence)を生成
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        
        
        
        //壁を生成するアクション(run)を生成
        let createWallAnimation = SKAction.run({
            //壁関連のノードをのせるノードを作成
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0.0)  //写真半分から地面にくっついて出てくる
            wall.zPosition = -50.0 //雲より手前、地面より奥
            
            //画面のY軸の中央値を定数化(使いやすくするために)
            let center_y = self.frame.size.height / 2
            // 壁のY座標を上下ランダムにさせるときの最大値(最大で画面の1/4のとこ生やす)
            let random_y_range = self.frame.size.height / 4
            // 下の壁のY軸の下限(真ん中 - 写真の1/2 - 画面の1/4)
            let under_wall_lowest_y = UInt32( center_y - wallTexture.size().height / 2 -  random_y_range / 2)
            // 1〜random_y_range(画面の1/4)までのランダムな整数を生成
            let random_y = arc4random_uniform( UInt32(random_y_range) )
            // Y軸の下限()にランダムな値()を足して、下の壁のY座標を決定(下限以上の数字が出る)
            let under_wall_y = CGFloat(under_wall_lowest_y + random_y)
            
            // キャラが通り抜ける隙間の長さ
            let slit_length = self.frame.size.height / 6
            
            // 下側の壁を作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0.0, y: under_wall_y)
            wall.addChild(under)
            
            //スプライトに物理演算を設定する(もともとNodeのプロパティにある)
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            under.physicsBody?.categoryBitMask = self.wallCategory         //underにcategoryBitMaskプロパティで自身のカテゴリーを設定
            
            //衝突の時に動かないように設定する
            under.physicsBody?.isDynamic = false
            
            
            // 上側の壁を作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0.0, y: under_wall_y + wallTexture.size().height + slit_length)
            
            wall.addChild(upper)
            wall.run(wallAnimation)
            
            self.wallNode.addChild(wall)
            
            // スプライトに物理演算を設定する
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            upper.physicsBody?.categoryBitMask = self.wallCategory        //upperにcategoryBitMaskプロパティで自身のカテゴリーを設定
            
            // 衝突の時に動かないように設定する
            upper.physicsBody?.isDynamic = false
            
            
 
        })
    

        
        // 次の壁作成までの待ち時間のアクションを作成
        let waitAnimation = SKAction.wait(forDuration: 2)
        
        // 壁を作成->待ち時間->壁を作成を無限に繰り替えるアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))
        
        wallNode.run(repeatForeverAnimation)
        
    }
    
    
    
    
    
    func setupBird(){
        //鳥の画像２種類読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .linear
        
        //２種類のテクスチャを交互に変更するアニメーションを作成
        let texuresAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(texuresAnimation)
        
        // スプライト(ノード)を作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        
        //半径が鳥の高さの半分(直径が鳥の高さ)の円形に物理演算を設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.0)
        
        //衝突した時に回転させない
        bird.physicsBody?.allowsRotation = false
        
        //衝突のカテゴリー設定
        bird.physicsBody?.categoryBitMask = birdCategory  //自分のカテゴリーを設定
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory   //(２つのカテゴリーのいずれかと)当たった時に跳ね返る動作を設定
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory | scoreCategory   //衝突相手としてこの３つ
    
        
        // アニメーションを設定
        bird.run(flap)
        
        // スプライトを追加する
        addChild(bird)
        
}
    

    func setupScoreLabel(){
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        scoreLabelNode.zPosition = 100 // 一番手前に表示する
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)
        
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        bestScoreLabelNode.zPosition = 100 // 一番手前に表示する
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
    }
    
    
    
    //didMoveによって画面ついた瞬間生まれる
    func setupScore() {
        
        //画像を割り当てる
        let scoreTexture = SKTexture(imageNamed: "meal")
        scoreTexture.filteringMode = .linear
        
        //あとで使うSpriteを生成
        let scoreSprite: SKSpriteNode! = SKSpriteNode(texture: scoreTexture)

        //壁と同じスピードにしたいから一旦壁画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        
        //移動する距離を計算(画面 + 写真)
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
        
        //画面外まで移動するアクションを作成(さっき計算した距離)
        let moveScore = SKAction.moveBy(x: -movingDistance, y: 0, duration: 4.0)
        
        //自身を取り除くアクションを作成
        let removeScore = SKAction.removeFromParent()
        
        //(完成)２つのアニメーション(さっき定義した)順に実行するアクション(スクロール)を生成
        let scoreScroll = SKAction.sequence([moveScore, removeScore])
    
        
        
        //スコアを生成するアクション(repeatForeverっていうSKActionでX秒に1回出てきて画面外で勝手に消える)
        let createScoreAnimation = SKAction.run ({
            
            let scorekari = SKNode()
            
            //画面の右端からスタート(高さはいじらず)
            scorekari.position = CGPoint(x: self.frame.size.width + scoreTexture.size().width / 2, y:0.0)
            
            //xはいじらず(画面の右端で)yをランダムで
            let random_y = arc4random_uniform(UInt32(Double(self.frame.size.height)))
            
            scoreSprite.position = CGPoint(x: 0.0, y:Double(random_y))
        
            scorekari.zPosition = -60
            
            scorekari.run(scoreScroll)
            
            
            //衝突判定を作る
            scoreSprite.physicsBody = SKPhysicsBody(circleOfRadius: scoreTexture.size().height / 2.0)
            scoreSprite.physicsBody?.isDynamic = false
            scoreSprite.physicsBody?.categoryBitMask = self.scoreCategory
            scoreSprite.physicsBody?.contactTestBitMask = self.birdCategory
            
            
            scorekari.addChild(scoreSprite)
            
            self.scoreNode.addChild(scorekari)
            

        })

        
        //次のスコア作成までの待ち時間のアクション
        let waitAnimation = SKAction.wait(forDuration: 1)
        
        //スコア(spriteとscroll)を作成-> 待ち時間 ->スコアを作成を無限に繰り返すアクション
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createScoreAnimation, waitAnimation]))
        
        scoreNode.run(repeatForeverAnimation)
       
        
        

        
        
        }
    
    
    func setupGameOverLabel(){
        
        gameOverLabelNode = SKLabelNode()
        gameOverLabelNode.fontColor = UIColor.red
        gameOverLabelNode.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        gameOverLabelNode.zPosition = 100 // 一番手前に表示する
        gameOverLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        gameOverLabelNode.text = "GameOver"
        self.addChild(gameOverLabelNode)
        
    }
        
    
    
    
    
    // SKPhysicsContactDelegateのメソッド。衝突したときに呼ばれる
    func didBegin(_ contact: SKPhysicsContact) {
        // ゲームオーバーのときは何もしない(壁と地面2回あたったら困るから)
        if scrollNode.speed <= 0 {
            return
        }
        
        // （もしゲームオーバーじゃないかつ、）もしスコア用の物体と衝突したら
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            
            
            score += 1
            scoreLabelNode.text = "Score:\(score)"  //データ型がどうのこうので更新必要
            
//            self.scoreSprite.removeAllChildren()
            
            
            
            // ベストスコア更新か確認する
            var bestScore = userDefaults.integer(forKey: "BEST")
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "Best Score:\(bestScore)"
                userDefaults.set(bestScore, forKey: "BEST")
                userDefaults.synchronize()
            }
            // もしそれ以外(壁か地面)と衝突したら
        } else {
            
            setupGameOverLabel()
            
            // スクロールを停止させる
            scrollNode.speed = 0
            
            bird.physicsBody?.collisionBitMask = groundCategory
            
            let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y) * 0.01, duration:1)
            bird.run(roll, completion:{
                self.bird.speed = 0
            })
        }
    }
    
    
    
    func restart() {
        score = 0
        scoreLabelNode.text = String("Score:\(score)")
        
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0.0
        
        wallNode.removeAllChildren()
        
        scoreNode.removeAllChildren()
        
        self.removeChildren(in: [gameOverLabelNode])
        
        bird.speed = 1
        scrollNode.speed = 1
    }
    
    
        
    }
    




