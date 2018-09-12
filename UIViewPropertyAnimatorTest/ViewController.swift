//
//  ViewController.swift
//  UIViewPropertyAnimatorTest
//
//  Created by Hairui on 10/9/18.
//  Copyright © 2018 Hairui's Organisation. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //
    var animator : UIViewPropertyAnimator!
    var animationDuration : TimeInterval = 3
    // Make theView a viewController property
    var theView : UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addAView()
        setupAnimation()
        
        
    }
    
}

// MARK: - Private Helpers
extension ViewController{
    private func setupAnimation(){
        // creating animator
        let timeParameter = UICubicTimingParameters(animationCurve: .linear)
        animator = UIViewPropertyAnimator(duration: animationDuration, timingParameters: timeParameter)
        
        // setting pausesOnCompletion to true to allow reversible animation
        animator.pausesOnCompletion = true
        
        // add an observer to observe if the animator is paused
        // observeValue function will be implemented later
        animator.addObserver(self, forKeyPath: #keyPath(UIViewPropertyAnimator.isRunning), options: [.new], context: nil)
        
        // add the animation
        animator.addAnimations {
            self.theView.transform = CGAffineTransform(translationX: self.view.bounds.width - self.theView.bounds.width, y: 0)
            self.theView.alpha = 0.2
        }
  
    }
}

extension ViewController{
    private func addAView(){
        // View Setup
        theView = UIView()
        theView.backgroundColor = .blue
        
        view.addSubview(theView)
        
        theView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            theView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            theView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            theView.heightAnchor.constraint(equalToConstant: 60),
            theView.widthAnchor.constraint(equalToConstant: 60)
            ])
        
        // Add a pangesture to the View
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        theView.addGestureRecognizer(panGesture)

    }
    
    @objc
    private func tap(_ tapGesture : UITapGestureRecognizer){
        guard let animator = animator else{
            return
        }
        if animator.isRunning == true{
            animator.stopAnimation(false)
            animator.finishAnimation(at: .end)
            let timeingParameter = UICubicTimingParameters(animationCurve: .linear)
            self.animator = UIViewPropertyAnimator(duration: animationDuration, timingParameters: timeingParameter)
            print("let me see the state aha = \(animator.state.rawValue)")
        }
    }
    
    
    @objc
    private func pan(_ panGesture : UIPanGestureRecognizer){
        switch panGesture.state{
        case .began:
            // You will see alot examples of creating the animator here.
            // But to create a more complex animator, it is often a good item
            // to implement the animtor outside of gesture
            break
        case .changed:
            // When we pan back and forth on the screen,
            // we update the fractionComplete to give the visual effect
            // that we are moving the blue box
            let direction : CGFloat = animator.isReversed ? -1 : 1
            animator.fractionComplete = direction * (panGesture.translation(in: view).x / view.bounds.width)
        case .ended:
            // When we lift the finger, we continue the animation
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        default:
            break
        }
    }
}

// MARK: - KVO
extension ViewController{
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(UIViewPropertyAnimator.isRunning){
            print("let me see if the thing is paused = \(!animator.isRunning)")
            // If the animator is paused
            if !animator.isRunning{
                animator.isReversed = !animator.isReversed
            }
        }
    }
}


