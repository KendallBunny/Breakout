//
//  ViewController.swift
//  Breakout
//
//  Created by kphillips on 3/19/15.
//  Copyright (c) 2015 Barrington High School. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollisionBehaviorDelegate {
    
    @IBOutlet weak var livesLabel: UILabel!
    var dynamicAnimator = UIDynamicAnimator()
    var paddle = UIView()
    var ball = UIView()
    var ballBehavior = UIDynamicItemBehavior()
    var collisionBehavior = UICollisionBehavior()
    var lives = 0
    var livesLabelText = ""
    var blocks : [UIView] = []
    var allObjects : [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetGame()
    }
    
    @IBAction func dragPaddle(sender: UIPanGestureRecognizer) {
        paddle.center = CGPointMake(sender.locationInView(view).x, paddle.center.y)
        dynamicAnimator.updateItemUsingCurrentState(paddle)
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying, atPoint p: CGPoint) {
        if item.isEqual(ball) && p.y > paddle.center.y {
            lives--
            livesLabel.text = "Lives: \(lives)"
            
            if lives > 0 {
                ball.center = view.center
                dynamicAnimator.updateItemUsingCurrentState(ball)
            }
            else {
                gameOver("get gud")
            }
            
        }
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint) {
        var item = UIView()
        var hiddenBlockCount = 0
        for block in blocks {
            if item1.isEqual(ball) && item2.isEqual(block) {
                if block.backgroundColor == UIColor.grayColor() {
                    block.backgroundColor = UIColor.lightGrayColor()
                }
                else if block.backgroundColor == UIColor.blackColor() {
                    block.backgroundColor = UIColor.grayColor()
                }
                else {
                    block.hidden = true
                    collisionBehavior.removeItem(block)
                }
                ballBehavior.addLinearVelocity(CGPointMake(0, 6), forItem: ball)
            }
            if block.hidden == true {
                hiddenBlockCount++
            }
        }
        if hiddenBlockCount == blocks.count {
            gameOver("In our society run by capitalism, everyone loses. Sorry.")
        }
    }
    
    func resetGame() {
        dynamicAnimator = UIDynamicAnimator(referenceView: view)
        allObjects = []
        
        paddle = UIView(frame: CGRectMake(view.center.x, view.center.y * 1.7, 80, 20))
        paddle.backgroundColor = UIColor.purpleColor()
        view.addSubview(paddle)
        
        ball = UIView(frame: CGRectMake(view.center.x, view.center.y, 20, 20))
        ball.layer.cornerRadius = 10
        ball.backgroundColor = UIColor.lightGrayColor()
        view.addSubview(ball)
        
        let pushBehaviour = UIPushBehavior(items: [ball], mode: UIPushBehaviorMode.Instantaneous)
        pushBehaviour.pushDirection = CGVectorMake(0.5, 1.0)
        pushBehaviour.magnitude = 0.1
        dynamicAnimator.addBehavior(pushBehaviour)
        
        let paddleBehaviour = UIDynamicItemBehavior(items: [paddle])
        paddleBehaviour.allowsRotation = false
        paddleBehaviour.density = 1000
        dynamicAnimator.addBehavior(paddleBehaviour)
        allObjects.append(paddle)
        
        ballBehavior = UIDynamicItemBehavior(items: [ball])
        ballBehavior.allowsRotation = false
        ballBehavior.elasticity = 1.0
        ballBehavior.friction = 0.0
        ballBehavior.resistance = 0.0
        dynamicAnimator.addBehavior(ballBehavior)
        allObjects.append(ball)
        
        var width = (Int)(view.bounds.size.width - 40)
        var xOffset = ((Int)(view.bounds.size.width) % 42) / 2
        for var x = xOffset; x < width; x += 42 {addBlock(x, y: 40, color: UIColor.blackColor())}
        for var x = xOffset; x < width; x += 42 {addBlock(x, y: 62, color: UIColor.grayColor())}
        for var x = xOffset; x < width; x += 42 {addBlock(x, y: 84, color: UIColor.grayColor())}
        for var x = xOffset; x < width; x += 42 {addBlock(x, y: 106, color: UIColor.grayColor())}
        for var x = xOffset; x < width; x += 42 {addBlock(x, y: 128, color: UIColor.grayColor())}
        for var x = xOffset; x < width; x += 42 {addBlock(x, y: 150, color: UIColor.lightGrayColor())}
        for var x = xOffset; x < width; x += 42 {addBlock(x, y: 172, color: UIColor.lightGrayColor())}
        for var x = xOffset; x < width; x += 42 {addBlock(x, y: 194, color: UIColor.lightGrayColor())}
        
        var blockBehavior = UIDynamicItemBehavior(items: blocks)
        blockBehavior.allowsRotation = false
        blockBehavior.density = 1000
        blockBehavior.elasticity = 1.0
        blockBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(blockBehavior)
        
        collisionBehavior = UICollisionBehavior(items: allObjects)
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        collisionBehavior.collisionMode = UICollisionBehaviorMode.Everything
        collisionBehavior.collisionDelegate = self
        dynamicAnimator.addBehavior(collisionBehavior)
        
        lives = 5
        livesLabel.text = "Lives: \(lives)"
        
        
    }
    
    func gameOver(message: String) {
        ball.removeFromSuperview()
        collisionBehavior.removeItem(ball)
        dynamicAnimator.updateItemUsingCurrentState(ball)
        paddle.removeFromSuperview()
        collisionBehavior.removeItem(paddle)
        dynamicAnimator.updateItemUsingCurrentState(paddle)
        
        let alert = UIAlertController(title: message, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        let resetAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.resetGame()
            
        }
        alert.addAction(resetAction)
        
        let quitAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Default) { (action) -> Void in
            exit(0)
        }
        
        alert.addAction(quitAction)
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func addBlock(x : Int, y: Int, color: UIColor) {
        var block = UIView(frame: CGRectMake((CGFloat)(x), (CGFloat)(y), 40, 20))
        block.backgroundColor = color
        view.addSubview(block)
        blocks.append(block)
        allObjects.append(block)
    }
}

