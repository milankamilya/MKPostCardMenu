//
//  MKFixedFluidView.swift
//  PostcardMenu
//
//  Created by Milan Kamilya on 23/09/15.
//  Copyright (c) 2015 innofied. All rights reserved.
//

import UIKit

enum MKFluidMenuSide {
    case Right
    case Left
}

protocol MKFixedFluidViewDelegate {
    func fixedFluidView(fixedFluidView:MKFixedFluidView, didOpenFromSide:MKFluidMenuSide);
    func fixedFluidView(fixedFluidView:MKFixedFluidView, didCloseToSide:MKFluidMenuSide);
}

class MKFixedFluidView: MKFluidView {

    //MARK: - PUBLIC PROPERTIES
    var destinationPoint: CGPoint? = CGPointMake(70, 290)
    var isOpen: Bool? = false
    var isTogglePressed: Bool? = false
    
    var delegate: MKFixedFluidViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    //MARK: - USER INTERACTION
    
    // touch Began
    func touchBegan(var touchPoint: CGPoint) {
        print("touchBegan")
        if !isOpen! {
            touchPoint = CGPointMake(touchPoint.x, destinationPoint!.y )
            super.initializeTouchRecognizer(touchPoint)
        }
    }
    
    // touch Moving
    func touchMoving(var touchPoint: CGPoint) {
        print("touchMoving \(touchPoint)\n")
        if !isOpen! {
            touchPoint = CGPointMake(touchPoint.x, destinationPoint!.y )
            super.movingTouchRecognizer(touchPoint)
        }
    }
    
    // touch End
    func touchEnded(touchPoint: CGPoint, callback onComplition:((Void) -> Void )?) {
        if !isOpen! && !isTogglePressed! {
            print("touchEnded \(destinationPoint!)")
            
            super.movingTouchRecognizer( destinationPoint!, animationBundle: AnimationBundle(duration: 0.3, delay: 0.0, dumping: 1.0, velocity: 1.0), callback: onComplition)
            isOpen = true
            delegate?.fixedFluidView(self, didOpenFromSide: MKFluidMenuSide.Right)

        }
        
        isTogglePressed = false
    }
    
    // Open / Close
    func toggleCurve(callback onComplition:((Void) -> Void )?) {
        print("toggleCurve")
        if isOpen! {
            super.endTouchRecognizer(destinationPoint!, callback: onComplition)
            isOpen = false
            delegate?.fixedFluidView(self, didCloseToSide: MKFluidMenuSide.Right)

            
        } else {
            super.initializeTouchRecognizer( destinationPoint!, animationBundle: AnimationBundle(duration: 0.3, delay: 0.0, dumping: 1.0, velocity: 1.0))
            isOpen = true
            
            delegate?.fixedFluidView(self, didOpenFromSide: MKFluidMenuSide.Right)
            
        }
        //isTogglePressed = true
    }
}
