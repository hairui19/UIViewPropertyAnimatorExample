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
    var progressWhenPaused : CGFloat = 0
    // Make theView a viewController property
    var theView : UIView!
    
    var isInterrupted : Bool = false
    
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
        
        animator.addCompletion { (position) in
            print("I am completed aha")
        }
        
        animator.addObserver(self, forKeyPath: #keyPath(UIViewPropertyAnimator.fractionComplete), options: [.new], context: nil)
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        theView.addGestureRecognizer(tapGesture)
        
    }
    
    @objc
    private func tap(_ tapGesture : UITapGestureRecognizer){
        interruptAnimation()
    }
    
    
    @objc
    private func pan(_ panGesture : UIPanGestureRecognizer){
        switch panGesture.state{
        case .began:
            // interrupt the animation if we detect
            // a start of a pan gesture
            interruptAnimation()
            
        case .changed:
            // set the interrupted back to false
            isInterrupted = false
            let direction : CGFloat = animator.isReversed ? -1 : 1
            
            // set the animator.fractionComplete
            animator.fractionComplete = direction * (panGesture.translation(in: view).x / view.bounds.width + direction * (progressWhenPaused))
        case .ended:
            // When we lift the finger, we continue the animation
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        default:
            break
        }
    }
    
    private func interruptAnimation(){
        guard let animator = animator else{
            return
        }
        if animator.isRunning == true{
            isInterrupted = true
            animator.pauseAnimation()
            progressWhenPaused = animator.fractionComplete
        }
    }
}

// MARK: - KVO
extension ViewController{
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(UIViewPropertyAnimator.isRunning){
            
            if !animator.isRunning && !isInterrupted{
                // If the animator is completed, we reverse
                // the animation and set progressWhenPaused back to
                // zero
                animator.isReversed = !animator.isReversed
                progressWhenPaused = 0
            }
        }
    }
}


