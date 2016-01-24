//
//  DisclosureFactory.swift
//  Whisper
//
//  Created by Rui Pedro Barbosa on 20/01/16.
//  Copyright © 2016 Hyper Interaktiv AS. All rights reserved.
//

import UIKit


let disclosureFactory = DisclosureFactory()

public func Disclosure(secret: Secret, toViewController viewContoller: UIViewController, completion: (() -> Void)? = {}) {
  disclosureFactory.craft(secret, toViewController: viewContoller, completion: completion)
}


class DisclosureFactory: UIView {

  struct Dimensions {
    static let disclosureHeight: CGFloat = 50
    static let textHorizontalOffset: CGFloat = 10
    static let textVerticalOffset: CGFloat = 8
    
    static var deviceWidth: CGFloat {
      return UIScreen.mainScreen().bounds.width
    }
    
    static var deviceHeight: CGFloat {
      return UIScreen.mainScreen().bounds.height
    }
  }
  
  
  private(set) lazy var backgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = ColorList.Disclosure.background
    view.alpha = 0.98
    view.clipsToBounds = true
    
    return view
  }()
  
  private(set) lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = FontList.Disclosure.title
    label.textColor = ColorList.Disclosure.title
    label.textAlignment = .Center
    label.numberOfLines = 1
    
    return label
  }()
  
  
  private(set) var completion: (() -> Void)? // TODO: Change method signature
  private(set) var secret: Secret?
  private(set) var displayTimer =  NSTimer()
  private(set) var shouldSilent = false
  
  
  // MARK: - Initializers
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    addSubview(backgroundView)
    backgroundView.addSubview(titleLabel)
    
    clipsToBounds = false
    userInteractionEnabled = false
    layer.shadowColor = UIColor.blackColor().CGColor
    layer.shadowOffset = CGSize(width: 0, height: -1.5)
    layer.shadowOpacity = 0.1
    layer.shadowRadius = 0.5
//    layer.shadowPath = UIBezierPath(rect: layer.bounds).CGPath
    
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationDidChange", name: UIDeviceOrientationDidChangeNotification, object: nil)
  }
  
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
  }

  
  // MARK: - Configuration
  
  func craft(secret: Secret, toViewController viewController: UIViewController, completion: (() -> Void)?) {
    
    shouldSilent = false
    
    //TODO: Check the type of viewContoller
    
    configureViewFor(secret)
    configureDisplayTimerFor(secret)
    revealTo(viewController)
    
    self.completion = completion
  }
  
  
  func configureViewFor(secret: Secret) {
    
    self.secret = secret
    titleLabel.text = secret.title
    titleLabel.textColor = secret.textColor
    backgroundView.backgroundColor = secret.backgroundColor
    titleLabel.sizeToFit()
    
    setUpFrames()
  }
  
  
  func configureDisplayTimerFor(secret: Secret) {
    displayTimer.invalidate()
    displayTimer = NSTimer.scheduledTimerWithTimeInterval(
      secret.duration,
      target: self,
      selector: "displayTimerDidFire",
      userInfo: nil,
      repeats: false)
  }
  
  
  func revealTo(viewController: UIViewController) {
    // TODO: Check class of viewController (navigation, tabbar, etc)
    
    print("revealTo(_:)\n")
    print("Dimensions.deviceHeight: \(Dimensions.deviceHeight)")
    
    viewController.view.addSubview(self)
    
    
    frame = CGRect(x: 0, y: Dimensions.deviceHeight, width: Dimensions.deviceWidth, height: Dimensions.disclosureHeight)
    
    
    backgroundView.frame = CGRect(x: 0, y: 0, width: Dimensions.deviceWidth, height: 0)
    
    print("frame before animation - y: \(frame.origin.y)")
    
    UIView.animateWithDuration(0.35, animations: {
      self.frame.origin.y = Dimensions.deviceHeight - Dimensions.disclosureHeight
      self.backgroundView.frame.size.height = Dimensions.disclosureHeight
    })
    
    print("frame after animation - y: \(frame.origin.y)")
  }
  
  
  // MARK: - Setup
  
  func setUpFrames() {
    
    print("setUPframes - Device width: \(Dimensions.deviceWidth), height: \(Dimensions.deviceHeight)")
    
    let yPos = shouldSilent ? Dimensions.deviceHeight : Dimensions.deviceHeight - Dimensions.disclosureHeight
    
    frame = CGRect(x: 0, y: yPos, width: Dimensions.deviceWidth, height: Dimensions.disclosureHeight)
    
    backgroundView.frame.size = CGSize(width: Dimensions.deviceWidth, height: Dimensions.disclosureHeight)
    
    titleLabel.frame.origin = CGPoint(x: Dimensions.textHorizontalOffset, y: Dimensions.textVerticalOffset)
    titleLabel.frame.size.width = Dimensions.deviceWidth - 2 * Dimensions.textHorizontalOffset
    
    titleLabel.frame.size.height = Dimensions.disclosureHeight - 2 * Dimensions.textVerticalOffset
    
    // TODO: We probably should limit the text height
    print("setUpFrames() frame - y: \(frame.origin.y)")
  }
  
  
  // MARK: - Actions
  
  func displayTimerDidFire() {
    shouldSilent = true
    silent()
  }
  
  
  func silent() {
    UIView.animateWithDuration(0.35, animations: {
      self.frame.origin.y = Dimensions.deviceHeight
      }, completion: { finished in
        self.completion?()
        self.displayTimer.invalidate()
        self.removeFromSuperview()
    } )
  }
  
  
  // MARK: Handling screen orientation
  
  func orientationDidChange() {
    // Set up frames
    print("Orientation did change")
    setUpFrames()
  }
}
