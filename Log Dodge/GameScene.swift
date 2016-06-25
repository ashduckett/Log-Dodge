//
//  GameScene.swift
//  Log Dodge
//
//  Created by Ash Duckett on 03/06/2016.
//  Copyright (c) 2016 Ash Duckett. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var water = SKSpriteNode()
    var boat = SKSpriteNode()
    var waterEffect = SKEmitterNode()
    var gameOver = false
    
    var gameOverLabel = SKLabelNode()
    var score = 0
    var scoreLabel = SKLabelNode()
    
    enum ColliderType: UInt32 {
        case Boat = 1
        case Object = 2
        case Gap = 4
    }
    
    
    func makeAndAddBackground() {
        let waterTexture = SKTexture(imageNamed: "ocean.png")
        water = SKSpriteNode(texture: waterTexture)
        
        water.size = self.frame.size
        water.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        self.addChild(water)
    }
    
    func makeAndAddBoat() {
        let boatTexture = SKTexture(imageNamed: "boat.png")
        
        boat = SKSpriteNode(texture: boatTexture)
        boat.position = CGPoint(x: CGRectGetMidX(self.frame), y: 30 + boat.size.height / 2)
        
        boat.physicsBody = SKPhysicsBody(rectangleOfSize: boat.size)
        boat.physicsBody?.dynamic = true
        boat.physicsBody!.affectedByGravity = false
        boat.physicsBody!.allowsRotation = false
        
        boat.physicsBody!.categoryBitMask = ColliderType.Boat.rawValue
        boat.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        boat.physicsBody!.collisionBitMask = 0
        
        self.addChild(boat)
        
        

    }
    
    func makeAndAddScoreLabel() {
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: self.frame.height - 70)
        self.addChild(scoreLabel)

    }
    
    func makeAndAddWaterParticles() {
        let waterEffectPath = NSBundle.mainBundle().pathForResource("WaterTrail", ofType: "sks")
        
        waterEffect = NSKeyedUnarchiver.unarchiveObjectWithFile(waterEffectPath!) as! SKEmitterNode
        waterEffect.position = CGPointMake(CGRectGetMidX(self.frame), boat.position.y - boat.size.height / 2)
        waterEffect.name = "waterTrail"
        waterEffect.targetNode = self.scene
        self.addChild(waterEffect)

    }
    
    func startLogsRolling() {
        
        let act = SKAction.sequence([SKAction.runBlock({
            self.runLog()
        }), SKAction.waitForDuration(3)])
        
        
        runAction(SKAction.repeatActionForever(act))
        
    }
    
    override func didMoveToView(view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        
        makeAndAddBackground()
        makeAndAddBoat()
        makeAndAddWaterParticles()
        makeAndAddScoreLabel()
        startLogsRolling()
    
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue {
        
            score++
            scoreLabel.text = String(score)
 
            
            
        } else {
        
            self.speed = 0
            gameOver = true
            waterEffect.paused = true
            
            
            gameOverLabel.fontName = "Helvetica"
            gameOverLabel.fontSize = 30
            gameOverLabel.text = "Game Over! Tap to play again"
            gameOverLabel.position = CGPointMake(CGRectGetMaxX(self.frame), CGRectGetMidY(self.frame))
            
            self.addChild(gameOverLabel)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        boat.removeActionForKey("moveToClick")
        waterEffect.removeActionForKey("moveToClick")

    }
    
    func runLog() {
        
        var leftLog = SKSpriteNode()
        var rightLog = SKSpriteNode()
        
        let gap = SKSpriteNode()
        
        gap.size.width = 30
        gap.size.height = 30
        
        let leftLogTexture = SKTexture(imageNamed: "logleft.png")
        let rightLogTexture = SKTexture(imageNamed: "logright.png")
        
        
        
        
        
        
        
        leftLog = SKSpriteNode(texture: leftLogTexture)
        rightLog = SKSpriteNode(texture: rightLogTexture)
        
        leftLog.physicsBody = SKPhysicsBody(rectangleOfSize: leftLog.size)
        leftLog.physicsBody!.dynamic = false
        leftLog.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        leftLog.physicsBody!.contactTestBitMask = ColliderType.Boat.rawValue
        leftLog.physicsBody!.collisionBitMask = 0
        
        
        rightLog.physicsBody = SKPhysicsBody(rectangleOfSize: leftLog.size)
        rightLog.physicsBody!.dynamic = false
        rightLog.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        rightLog.physicsBody!.contactTestBitMask = ColliderType.Boat.rawValue
        rightLog.physicsBody!.collisionBitMask = 0
      
        
        self.addChild(leftLog)
        self.addChild(rightLog)
        self.addChild(gap)
        
        leftLog.position = CGPoint(x: CGRectGetMidX(self.frame) - leftLog.size.width / 2, y: self.frame.height + leftLog.size.height / 2)
        rightLog.position = CGPoint(x: CGRectGetMidX(self.frame) + rightLog.size.width / 2, y: self.frame.height + rightLog.size.height / 2)
        
        let gapWidth = CGFloat(80.0)
        
        
        
        
        let minX = gapWidth / 2;
        let maxX = UInt32(self.frame.width - gapWidth / 2)
        
        let rand = CGFloat(arc4random_uniform(maxX)) + minX
        let gapPosition = rand

        if(gapPosition < gapWidth / 2 || gapPosition > self.frame.width - gapWidth / 2) {
            print("Too far off one of the edges")
        }
        
        
        
        
        
        leftLog.position.x = gapPosition - leftLog.size.width / 2 - gapWidth / 2
        rightLog.position.x = gapPosition + rightLog.size.width / 2 + gapWidth / 2
        
        
        
        gap.position.x = gapPosition
        gap.position.y = leftLog.position.y
        gap.size.width = gapWidth
        
        
        
        
        let endingYPosition = 0 - leftLog.size.height / 2
        
        
        
        
        let animateToBottomOfScreen = SKAction.moveToY(endingYPosition, duration: 5)
        
        
        
        gap.physicsBody = SKPhysicsBody(rectangleOfSize: gap.size)
        gap.physicsBody!.dynamic = false
        
        
        gap.physicsBody!.categoryBitMask = ColliderType.Gap.rawValue
        gap.physicsBody!.contactTestBitMask = ColliderType.Boat.rawValue
        gap.physicsBody!.collisionBitMask = 0
        
        
        // Is there a way to run the same action on multiple sprites in a single call?
        
        // Move the left log to the bottom of the screen and remove it on completion
        leftLog.runAction(animateToBottomOfScreen, completion: {
            leftLog.removeFromParent()
        })
        
        // Move the right log to the bottom of the screen and remove it on completion
        rightLog.runAction(animateToBottomOfScreen, completion: {
            rightLog.removeFromParent()
            
        })
        
        // Move the gap to the bottom of the screen and remove it on completion
        gap.runAction(animateToBottomOfScreen, completion: {
            gap.removeFromParent()
        })
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !gameOver {
            let touch = touches.first
            var location = touch?.locationInNode(self)
        
        
            let boatPos = self.boat.position
        
            location!.y = boatPos.y
        
        
        
            let leftSideOfWater = CGRectGetMidX(self.frame) - water.size.width / 2
        
        
            if location!.x < (0.0 + boat.size.width / 2) {
                print("position to far to the left")
                location!.x = leftSideOfWater + boat.size.width / 2
            }
        
            if location!.x > (self.frame.width - boat.size.width / 2) {
                location!.x = self.frame.width - boat.size.width / 2
            }
        
        
        
        
            let one = Float(location!.x - boatPos.x)
            let two = Float(location!.y - boatPos.y)
        
            let distance = Double(sqrtf((one) * (one) + (two) * (two)))
        
            let moveToClick = SKAction.moveTo(location!, duration: distance / 500)
        
            var particlePos = location!
        
          //  particlePos.y -= boat.size.height
        
            let moveParticles = SKAction.moveToX(particlePos.x, duration: distance / 500)
        
     
        
            boat.runAction(moveToClick, withKey: "moveToClick")
            waterEffect.runAction(moveParticles, withKey: "moveToClick")
     
        
        } else {
            gameOver = false
            score = 0
            scoreLabel.text = "0"
    
            
            
           // boat.position = CGPoint(x: CGRectGetMidX(self.frame), y: 30 + boat.size.height / 2)
            
            self.removeAllChildren()
            
            
            makeAndAddBackground()
            makeAndAddBoat()
            makeAndAddWaterParticles()
            makeAndAddScoreLabel()
          //  startLogsRolling()
            
            self.speed = 1
            
        }
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
