//
//  ViewController.swift
//  PostcardMenu
//
//  Created by Milan Kamilya on 21/09/15.
//  Copyright (c) 2015 innofied. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var fixedFluidView: MKFixedFluidView?
    var springMenu: MKSpringMenu!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        fixedFluidView = MKFixedFluidView(frame: self.view.frame)
        fixedFluidView?.fillColor = UIColor.orangeColor()
        fixedFluidView?.directionOfBouncing = .SurfaceTensionLeftInward
        fixedFluidView?.delegate = self
        self.view.addSubview(fixedFluidView!)
        
        var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("tapRecognized:"))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        
        
        springMenu = MKSpringMenu(frame: CGRectMake(0, 80, 200, 200))
        //self.view.addSubview(springMenu)
        springMenu.numberOfButtons = 3
       
        springMenu.arrayOfImagesForButtonNormalState = Array(arrayLiteral:  UIImage(named: "1")!, UIImage(named: "2")!, UIImage(named: "3")!, UIImage(named: "4")!, UIImage(named: "5")!, UIImage(named: "6")!, UIImage(named: "7")!, UIImage(named: "8")!)
        
        springMenu.initialSetup()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    func tapRecognized(recognizer: UITapGestureRecognizer) {
        fixedFluidView?.toggleCurve(callback: nil)
    }
    
//    
//    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
//        
//        
//        if touches.count == 1 {
//            for touch in touches {
//                
//                let touchLocal: UITouch = touch as! UITouch
//                var point: CGPoint = touchLocal.locationInView(touchLocal.view)
//                //println("touchesBegan VC \(point)")
//                fixedFluidView?.touchBegan(point)
//            }
//        }
//    }
//    
//    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
//        
//        if touches.count == 1 {
//            for touch in touches {
//                let touchLocal: UITouch = touch as! UITouch
//                
//                var point: CGPoint = touchLocal.locationInView(touchLocal.view)
//                //println("touchesMoved VC  \(point)")
//
//                fixedFluidView?.touchMoving(point)
//            }
//        }
//    }
//    
//    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
//        if touches.count == 1 {
//            for touch in touches {
//                let touchLocal: UITouch = touch as! UITouch
//                
//                var point: CGPoint = touchLocal.locationInView(touchLocal.view)
//                //println("touchesEnded VC \(point)")
//
//                fixedFluidView?.touchEnded(point)
//            }
//        }
//    }
//    
//    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
//        if touches.count == 1 {
//            for touch in touches {
//                let touchLocal: UITouch = touch as! UITouch                
//                var point: CGPoint = touchLocal.locationInView(touchLocal.view)
//                //println("touchescancelled VC \(point)")
//                
//                fixedFluidView?.touchEnded(point)
//
//            }
//        }
//    }
    

}

extension ViewController : MKFixedFluidViewDelegate {
    func fixedFluidView(fixedFluidView: MKFixedFluidView, didCloseToSide: MKFluidMenuSide) {
    }
    
    func fixedFluidView(fixedFluidView: MKFixedFluidView, didOpenFromSide: MKFluidMenuSide) {
        springMenu.arrangeButtonsRightward()
    }
    
}

