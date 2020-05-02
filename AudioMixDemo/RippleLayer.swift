//
//  RippleLayer.swift
//  Blaster
//
//  Created by MyMAC on 05/12/18.
//  Copyright © 2018 MyMAC. All rights reserved.
//

import UIKit
import Foundation
class RippleLayer: CAReplicatorLayer {
    fileprivate var rippleEffect: CALayer?
    private var animationGroup: CAAnimationGroup?
    var rippleRadius: CGFloat = 150.0
    var rippleRepeatCount: CGFloat = 10000.0
    var rippleWidth: CGFloat = 8
    var strScreenStatus = String()
    
    override init() {
        super.init()
        setupRippleEffect()
        
        repeatCount = Float(rippleRepeatCount)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
        rippleEffect?.bounds = CGRect(x: 0, y: 0, width: rippleRadius*2, height: rippleRadius*2)
        rippleEffect?.cornerRadius = rippleRadius
            rippleEffect?.backgroundColor = UIColor(red: 239.0/255.0, green: 122.0/255.0, blue: 132.0/255.0, alpha: 1.0).cgColor
        instanceCount = 3
        instanceDelay = 0.4
    }
    
    func setupRippleEffect() {
        rippleEffect = CALayer()
        rippleEffect?.borderWidth = CGFloat(1)
            rippleEffect?.borderColor = UIColor(red: 239.0/255.0, green: 122.0/255.0, blue: 132.0/255.0, alpha: 1.0).cgColor
        rippleEffect?.opacity = 0
        addSublayer(rippleEffect!)
    }
    
    func startAnimation() {
        setupAnimationGroup()
        rippleEffect?.add(animationGroup!, forKey: "ripple")
    }
    
    func stopAnimation() {
        rippleEffect?.removeAnimation(forKey: "ripple")
    }
    
    func setupAnimationGroup() {
        let duration: CFTimeInterval = 3
        
        let group = CAAnimationGroup()
        group.duration = duration
        group.repeatCount = self.repeatCount
        group.timingFunction = CAMediaTimingFunction(name: .default)
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
        scaleAnimation.fromValue = 0.0;
        scaleAnimation.toValue = 1.0;
        scaleAnimation.duration = duration
        
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.duration = duration
        let fromAlpha = 1.0
        opacityAnimation.values = [fromAlpha, (fromAlpha * 0.5), 0];
        opacityAnimation.keyTimes = [0, 0.2, 1];
        
        group.animations = [scaleAnimation, opacityAnimation]
        animationGroup = group;
        animationGroup!.delegate = self;
    }
}
extension RippleLayer: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let count = rippleEffect?.animationKeys()?.count , count > 0 {
            rippleEffect?.removeAllAnimations()
        }
    }
}
