//
//  MKSpringMenu.swift
//  PostcardMenu
//
//  Created by Milan Kamilya on 28/09/15.
//  Copyright (c) 2015 innofied. All rights reserved.
//

import UIKit

protocol MKSpringMenuDelegate {
    func springMenu( menu: MKSpringMenu, shouldhighlightedButtonIndex: Int ) -> Bool
    func springMenu( menu: MKSpringMenu, selectedButtonIndex: Int )
    func springMenu( menu: MKSpringMenu, deselectedButtonIndex: Int )
}

enum MKSpringMenuDirection {
    case Left
    case Right
}

class MKSpringMenu: UIView {

    let WidthOfButton: CGFloat = 50.0
    let HeightOfButton: CGFloat = 50.0
    
    //MARK: - PUBLIC PROPERTIES
    var arrayOfImagesForButtonNormalState: [UIImage]? 
    var arrayOfImagesForButtonSelectedState: [UIImage]?
    var numberOfButtons: Int? = 3
    var direction: MKSpringMenuDirection? = .Left
    var backgroundColorForCentralButton: UIColor?
    
    //MARK: - PRIVATE PROPERTIES
    private var centralButton: UIButton?
    private var arrayOfButton: [UIButton]?
    
    //MARK: - INITIALIZATION METHOD
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - USER INTERACTION
    
    //MARK: - UTILITY
    
    func initialSetup() {
        
        centralButton = UIButton(frame: CGRectMake( CGFloat(0.0), CGFloat(0.0) , WidthOfButton, HeightOfButton))
        centralButton?.tag = 0
        centralButton?.center = CGPointMake( self.frame.width - CGFloat(20), self.frame.height / CGFloat(2.0) )
        centralButton?.setImage( arrayOfImagesForButtonNormalState?[0] , forState: UIControlState.Normal )
        centralButton?.addTarget(self, action: Selector("closeButtons"), forControlEvents: UIControlEvents.TouchUpInside)
        centralButton?.backgroundColor = backgroundColorForCentralButton
        self.addSubview(centralButton!)
        
        arrayOfButton = Array()
        
        for i in 0..<self.numberOfButtons! {
            let supportButton: UIButton = UIButton(frame: CGRectMake(0, 0, 50, 50))
            supportButton.setImage( arrayOfImagesForButtonNormalState?[i+1] , forState: UIControlState.Normal)
            supportButton.tag = i+1
            supportButton.center = centralButton!.center
            self.addSubview(supportButton)
            arrayOfButton?.append(supportButton)
        }
        
    }
    
    func arrangeButtons() {
        
        switch direction! {
            case .Left :
                self.arrangeButtonsLeftward()
            case .Right :
                self.arrangeButtonsRightward()
        }
        
    }
    
    func arrangeButtonsLeftward() {
        
        for i in 0..<self.numberOfButtons!{
            for button in self.arrayOfButton! {
                
                if button.tag == (i+1) {
                    
                    let radius : Double = 100.0
                    let angle : Double = Double(i) * 90.0 / Double(self.numberOfButtons! - 1)
                    
                    let originX : CGFloat = CGFloat ( radius * -sin(M_PI / 180.0 * (angle + 45.0)))
                    let originY : CGFloat = CGFloat ( radius * -cos(M_PI / 180.0 * (angle + 45.0)))
                    
                    UIView.animateWithDuration(0.6, delay:Double(i)*0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 10.0, options: [UIViewAnimationOptions.CurveEaseInOut, UIViewAnimationOptions.AllowUserInteraction], animations: { () -> Void in
                        
                            button.center = CGPoint(x: originX + self.centralButton!.center.x , y: (self.centralButton!.center.y - originY) )
                        
                        }, completion: nil)
                }
            }
            
        }
    }

    func arrangeButtonsRightward() {
        for i in 0..<self.numberOfButtons!{
            
            let supportButton: UIButton = UIButton(frame: CGRectMake(0, 0, 50, 50))
            supportButton.setImage( arrayOfImagesForButtonNormalState?[i+1] , forState: UIControlState.Normal)
            supportButton.tag = i+1
            supportButton.center = centralButton!.center
            self.addSubview(supportButton)
            
            if supportButton.tag == (i+1) {
                
                let radius : Double = 100.0
                let angle : Double = Double(i) * 90.0 / Double(self.numberOfButtons! - 1)
                
                let originX : CGFloat = CGFloat ( radius * sin(M_PI / 180.0 * (angle + 45.0)))
                let originY : CGFloat = CGFloat ( radius * -cos(M_PI / 180.0 * (angle + 45.0)))
                
                UIView.animateWithDuration(0.6, delay:Double(i)*0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 10.0, options: [UIViewAnimationOptions.CurveEaseInOut, UIViewAnimationOptions.AllowUserInteraction], animations: { () -> Void in
                    
                    supportButton.center = CGPoint(x: originX + self.centralButton!.center.x , y: (self.centralButton!.center.y - originY) )
                    
                    }, completion: nil)
            }
            
        }
    }
    
    func closeButtons() {
        
        for i in 0..<self.numberOfButtons!{
            for backButton in self.arrayOfButton! {
                if backButton.tag == self.numberOfButtons! - i {
                    
                    UIView.animateWithDuration(0.6, delay:Double(i)*0.1, usingSpringWithDamping: 0.9, initialSpringVelocity: 10.0, options: [.CurveEaseInOut, .AllowUserInteraction] , animations: { () -> Void in
                        backButton.center = CGPoint(x: self.centralButton!.center.x, y: self.centralButton!.center.y)
                        
                        }, completion: nil)
                }
            }
        }

    }

    
}


