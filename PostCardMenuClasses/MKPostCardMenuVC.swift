//
//  MKPostCardMenuVC.swift
//  PostcardMenu
//
//  Created by Milan Kamilya on 21/09/15.
//  Copyright (c) 2015 innofied. All rights reserved.
//

import UIKit

enum MKPostCardMenuAppearanceDirection {
    case LeftToRight
    case RightToLeft
}
typealias onComplitionType = (finished: Bool?) -> Void


@objc protocol MKPostCardMenuVCDelegate: NSObjectProtocol {
    optional func postCardMenuSlidingIn()
    optional func postCardMenuSlidingOut()
    optional func postCardMenu(menu: MKPostCardMenuVC, selectedButtonTag: Int)
}

class MKPostCardMenuVC: UIViewController {

    
    //MARK:- CONTANTS
    let kSlideAnimationDuration = 0.3
    let kBlurMaximumRadius = 10.0
    
    //MARK:- STORYBOARD COMPONENT
    
    //MARK:- PUBLIC PROPERTIES
    private var menuViewControllerStorage: UIViewController?
    var menuViewController: UIViewController? {
        set{
            if self.menuViewControllerStorage != newValue {
                self.menuViewControllerStorage?.willMoveToParentViewController(nil)
                self.menuViewControllerStorage?.removeFromParentViewController()
                self.menuViewControllerStorage = newValue
            }
        }
        get{
            return self.menuViewControllerStorage
        }
    }
    
    private var contentViewcontrollerStorage: UIViewController?
    var contentViewcontroller: UIViewController? {
        set{
            if self.contentViewcontrollerStorage != newValue {
                self.contentViewcontrollerStorage?.willMoveToParentViewController(nil)
                self.contentViewcontrollerStorage?.removeFromParentViewController()
                self.contentViewcontrollerStorage = newValue
            }
        }
        get{
            return self.contentViewcontrollerStorage
        }
    }
    var panGestureEnabled: Bool? {
        set{
            self.panGesture?.enabled = newValue!
        }
        get{
            return self.panGesture?.enabled
        }
    }
    var menuWidth: CGFloat? = 276
    var slideDirection: MKPostCardMenuAppearanceDirection? = .LeftToRight
    var fluidView: MKFixedFluidView?
    var menuWasOpenAtPanBegin: Bool?
    
    // It must be set before at the time of assigning.
    var imageArrayForButton: [String]?
    
    
    
    //MARK:- PRIVATE PROPERTIES
    private var contentViewWidthWhenMenuIsOpen: CGFloat? = -1
    private var panGesture: UIPanGestureRecognizer?
    private var tapGesture: UITapGestureRecognizer?
    
    //MARK:- INIT
    
    init( menuViewController: UIViewController, contentViewController: UIViewController?) {
        super.init(nibName: nil, bundle: nil)
        
        self.menuViewController = menuViewController
        self.contentViewcontroller = contentViewController
        
    }

    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.menuViewController = nil
        self.contentViewcontroller = nil
        self.menuWidth  = 276
        contentViewWidthWhenMenuIsOpen = -1
        
    }
    
    
    //MARK: - LIFE CYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if contentViewWidthWhenMenuIsOpen >= 0 {
            self.menuWidth = CGRectGetWidth(self.view.bounds) - contentViewWidthWhenMenuIsOpen!
        }
        
        self.addChildViewController( self.contentViewcontroller! )
        self.contentViewcontroller!.view.frame = self.view.bounds
        self.view.addSubview(self.contentViewcontroller!.view)
        //self.contentViewController!.didMoveToParentViewController(self)
        
        self.fluidView = MKFixedFluidView(frame: self.frameForFluidView())
        //self.fluidView.blurTintColor = UIColor.colorWithWhite(0.85, alpha: 1.0)
        self.fluidView?.fillColor = UIColor(red: 182.0/255.0, green: 168.0/255.0, blue: 224.0/255.0, alpha: 1.0)
        self.fluidView?.hidden = false
        self.fluidView!.directionOfBouncing = .SurfaceTensionRightInward
        self.fluidView!.addGestureRecognizer(self.getTapGesture())
        
        self.configurePanGesture()
        self.loadMenuViewControllerViewIfNeeded()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !self.isMenuOpen() {
            self.contentViewcontroller?.view.frame = self.view.bounds
        }
        
        self.contentViewcontroller?.beginAppearanceTransition(true, animated: animated)
        if self.menuViewController!.isViewLoaded() && (self.menuViewController?.view.superview != nil) {
            self.menuViewController?.beginAppearanceTransition(true, animated: animated)
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.contentViewcontroller?.endAppearanceTransition()
        if self.menuViewController!.isViewLoaded() && (self.menuViewController?.view.superview != nil) {
            self.menuViewController?.endAppearanceTransition()
        }
    }
    override func viewDidDisappear(animated: Bool) {
        
        self.contentViewcontroller?.beginAppearanceTransition(false, animated: animated)
        if self.menuViewController!.isViewLoaded() {
            self.menuViewController?.beginAppearanceTransition(false, animated: animated)
        }
        
        super.viewDidDisappear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        self.contentViewcontroller?.endAppearanceTransition()
        if self.menuViewController!.isViewLoaded() {
            self.menuViewController?.endAppearanceTransition()
        }
        
        super.viewWillDisappear(animated)
    }
    
    func loadMenuViewControllerViewIfNeeded() {
        if !(self.menuViewController!.view.window != nil) {
            self.addChildViewController(self.menuViewController!)
            self.menuViewController!.view.frame = self.frameForMenuViewDisappeared()
            self.menuViewController!.view.autoresizingMask = self.menuViewAutoresizingMaskAccordingToCurrentSlideDirection()
            self.view.insertSubview(self.menuViewController!.view, aboveSubview: self.fluidView!)
            self.menuViewController!.didMoveToParentViewController(self)
        }
    }
    
    //MARK: - MEMORY WARNING HANDLER
    override func didReceiveMemoryWarning() {
        // Basic object clean up code which will be retrive later when coming back to view controller
    }
    
    //MARK: ROTATION
    
    override func shouldAutomaticallyForwardAppearanceMethods() -> Bool {
        return false
    }
    
    override func shouldAutomaticallyForwardRotationMethods() -> Bool {
        return true
    }
    
    
//    override func shouldAutorotate() -> Bool {
//        return self.menuViewController!.shouldAutorotate() && self.contentViewcontroller!.shouldAutorotate() && self.panGesture!.state == UIGestureRecognizerState.Changed
//    }
    
    override func supportedInterfaceOrientations() -> Int {
        return self.menuViewController!.supportedInterfaceOrientations() & self.contentViewcontroller!.supportedInterfaceOrientations()
    }
    /*
    - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
    {
    return	[self.menuViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation] &&
    [self.contentViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    }
    */
    
    
    //MARK:- ANIMATION
    
    @IBAction func toggleMenuAnimated(sender: AnyObject) {
        if self.isMenuOpen() {
            self.closeMenuAnimated(true, completion: nil)
        }
        else {
            self.openMenuAnimated(true, completion: nil)
        }
    }
    
    func openMenuAnimated(animated: Bool, completion:onComplitionType? ) {
        
        var duration: NSTimeInterval = animated ? kSlideAnimationDuration : 0
        self.showHideFluidView(true)
        //self.fluidView.createSnapshot()
        
        self.menuViewController!.beginAppearanceTransition(true, animated: animated)
        //self.contentViewcontroller.viewWillSlideOut(animated, inSlideMenuController: self)

        self.fluidView!.alpha = 0.0
        //self.fluidView!.forceUpdate(true, blurWithDegree: 1.0)
        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {        self.fluidView!.alpha = 1.0
            self.menuViewController!.view.frame = self.frameForMenuView()
            
            //TODO: - Open Menu Animation
            
            }, completion: {(finished: Bool) in
                self.menuViewController!.endAppearanceTransition()
                // self.contentViewcontroller .viewDidSlideOut(animated, inSlideMenuController: self)
                self.configurePanGesture()
                if completion != nil {
                    completion!(finished: finished)
                }
                
        })
    }
    
    func closeMenuAnimated(animated: Bool, completion:onComplitionType? ) {
        var duration: NSTimeInterval = animated ? kSlideAnimationDuration : 0
        self.menuViewController!.beginAppearanceTransition(false, animated: animated)
        //self.contentViewController.viewWillSlideIn(animated, inSlideMenuController: self)

            
        //TODO: - Close Menu Animation
        self.fluidView?.toggleCurve(callback: {() -> Void in
                self.menuViewController!.endAppearanceTransition()
                //self.contentViewController.viewDidSlideIn(animated, inSlideMenuController: self)
                self.menuViewController!.view.frame = self.frameForMenuViewDisappeared()
                
                self.showHideFluidView(false)
                self.configurePanGesture()
            
            
            })
        
    }
    
    func closeMenuBehindContentViewController(contentViewController: UIViewController, animated: Bool, completion: onComplitionType? ) {
        
        var swapContentViewController:Void -> Void = {}
        
        if contentViewController != self.contentViewcontroller {
            
            swapContentViewController = {
                var frame: CGRect = self.contentViewcontroller!.view.frame
                self.contentViewcontroller!.view.removeGestureRecognizer(self.getPanGesture())
                self.contentViewcontroller!.beginAppearanceTransition(false, animated: false)
                self.contentViewcontroller!.willMoveToParentViewController(nil)
                self.contentViewcontroller!.view.removeFromSuperview()
                self.contentViewcontroller!.removeFromParentViewController()
                self.contentViewcontroller!.endAppearanceTransition()
                self.contentViewcontroller = contentViewController
                self.contentViewcontroller!.view.frame = frame
                self.contentViewcontroller!.view.addGestureRecognizer(self.getPanGesture())
                self.contentViewcontroller!.beginAppearanceTransition(true, animated: false)
                self.addChildViewController( self.contentViewcontroller! )
                self.view.addSubview(self.contentViewcontroller!.view)
                self.contentViewcontroller!.didMoveToParentViewController(self)
                self.contentViewcontroller!.endAppearanceTransition()
                
            }
        }
        if swapContentViewController != nil {
            swapContentViewController()
        }
        if self.isMenuOpen() {
            self.closeMenuAnimated(animated, completion: completion)
        }
    }
    
    
    
    //MARK:- GESTURE
    
    func getTapGesture() -> UITapGestureRecognizer {
        if self.tapGesture == nil {
            self.tapGesture = UITapGestureRecognizer(target: self, action: Selector("tapGestureTriggered:"))
        }
        return self.tapGesture!
    }
    
    func tapGestureTriggered(tapGesture: UITapGestureRecognizer) {
        if tapGesture.state == UIGestureRecognizerState.Ended {
            self.closeMenuAnimated(true, completion: nil)
        }
    }
    
    
    func getPanGesture() -> UIPanGestureRecognizer {
        if !(panGesture != nil) {
            panGesture = UIPanGestureRecognizer(target: self, action: "panGestureTriggered:")
            panGesture!.maximumNumberOfTouches = 1
        }
        return panGesture!
    }
    
    func panGestureTriggered(panGesture: UIPanGestureRecognizer) {
        

        var controlPoint = panGesture.translationInView(self.fluidView!)
        println("PanGesture :: \(controlPoint)")

        if controlPoint.x < 0 {
            controlPoint.x = self.fluidView!.frame.size.width + controlPoint.x
        }
        println("PanGesture :: \(controlPoint)")

        if panGesture.state == UIGestureRecognizerState.Began {
            self.menuWasOpenAtPanBegin = self.isMenuOpen()
            if self.menuWasOpenAtPanBegin! {
                //self.contentViewcontroller!.viewWillSlideIn(true, inSlideMenuController: self)
            }
            else {
                //self.contentViewController.viewWillSlideOut(true, inSlideMenuController: self)
            }
            self.showHideFluidView(true)
            if !self.menuWasOpenAtPanBegin! {
                //self.fluidView.createSnapshot()
            }
            self.fluidView!.touchBegan(controlPoint)
        }
        
        
        // TODO: Decide Direction Of Appearance
        
        
        
        self.fluidView!.touchMoving(controlPoint)
        
        
        var translation: CGPoint = panGesture.translationInView(panGesture.view!)
        if self.slideDirection == MKPostCardMenuAppearanceDirection.RightToLeft {
            translation.x *= -1
        }
        var blurDegree: CGFloat = translation.x / self.view.bounds.size.width
        if self.menuWasOpenAtPanBegin! {
            blurDegree *= -1
        }
        blurDegree = min(max(blurDegree, 0.0), 1.0)
        if self.menuWasOpenAtPanBegin! {
            blurDegree = 1 - blurDegree
        }
        //NSLog("blurRadius: %f", blurDegree)
        //self.fluidView!.forceUpdate(false, blurWithDegree: blurDegree)
        if self.menuWasOpenAtPanBegin! {
            var startFrame: CGRect = self.frameForMenuView()
            var endFrame: CGRect = self.frameForMenuViewDisappeared()
            var menuFrame: CGRect = startFrame
            menuFrame.origin.x = (1 - blurDegree) * endFrame.origin.x + blurDegree * startFrame.origin.x
            self.menuViewController!.view.frame = menuFrame
        }
        
        
        if panGesture.state == UIGestureRecognizerState.Ended {
            
            self.fluidView!.touchEnded(controlPoint, callback: { (finished) -> Void in
                self.configurePanGesture()
                
                self.menuViewController!.view.frame = self.frameForMenuView()
                self.view.addSubview(self.menuViewController!.view)
            })
            
            // TODO: Animation for Menus
            
            
            
            
        }
    }
    
    func configurePanGesture() {
        if (self.fluidView!.superview != nil) {
            self.contentViewcontroller!.view.removeGestureRecognizer(self.getPanGesture())
            self.menuViewController!.view.addGestureRecognizer(self.getPanGesture())
        }
        else {
            self.menuViewController!.view.removeGestureRecognizer(self.getPanGesture())
            self.contentViewcontroller!.view.addGestureRecognizer(self.getPanGesture())
        }
    }
    
    
    //MARK:- UTILITY METHODS
    func showHideFluidView(show: Bool) {
        if show {
            if (self.fluidView!.superview != nil) {
                self.fluidView!.removeFromSuperview()
            }
            self.view.insertSubview(self.fluidView!, belowSubview: self.menuViewController!.view)
            println(" FluidView = \(self.fluidView!) superview\(self.fluidView?.superview)")
            self.fluidView!.alpha = 1
        }
        else {
            self.fluidView!.removeFromSuperview()
        }
    }
    
    func isMenuOpen() -> Bool {
        return CGRectEqualToRect( self.menuViewController!.view.frame , self.frameForMenuView());
    }
    
    func frameForFluidView() -> CGRect {
        var result: CGRect = self.view.bounds
        return result
    }
    
    func frameForMenuView() -> CGRect {
        
        var result: CGRect = self.frameForFluidView()
        if self.slideDirection == MKPostCardMenuAppearanceDirection.RightToLeft {
            result.origin.x = result.size.width - self.menuWidth!;
        }
        result.size.width = self.menuWidth!;
    
        return result;
    }
    
    func frameForMenuViewDisappeared() -> CGRect {
        var result: CGRect = self.frameForMenuView()
        if self.slideDirection == MKPostCardMenuAppearanceDirection.LeftToRight {
            result.origin.x -= result.size.width
        }
        else {
            result.origin.x += result.size.width
        }
        return result
    }
    
    func menuViewAutoresizingMaskAccordingToCurrentSlideDirection() -> UIViewAutoresizing {
        var resizingMask: UIViewAutoresizing = UIViewAutoresizing.FlexibleHeight
        if self.slideDirection == MKPostCardMenuAppearanceDirection.LeftToRight {
            resizingMask = resizingMask | UIViewAutoresizing.FlexibleRightMargin
        }
        else {
            resizingMask = resizingMask | UIViewAutoresizing.FlexibleLeftMargin
        }
        return resizingMask
    }
    
}








