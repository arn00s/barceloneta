//
//  Barceloneta.swift
//
//  Created by Arnaud Schloune on 17/05/16.
//  Copyright © 2016 Arnaud Schloune. All rights reserved.
//

//Some parts are based on : https://github.com/Produkt/RubberBandEffect

import UIKit

protocol BarcelonetaDelegate:class {
    func barcelonetaDidMovedUp()
    func barcelonetaDidMovedDown()
    func barcelonetaDidRestore()
    func barcelonetaDidChangeValue(view:Barceloneta,value:Double)
    func barcelonetaDidRelease(view:Barceloneta)
}

class Barceloneta: UIView {
    //Configuration variables
    var loops = true
    var initialValue = 0
    var verticalLimit:CGFloat = 50.0
    var value:Double = 0.0
    var minimumValue:Double = 0.0
    var maximumValue:Double = 50.0
    var timerInterval = 0.3
    var incrementalSettings:[(range:Range<Int>,value:Double)] = [(range:0..<50,value:1.0),(range:50..<70,value:2.0),(range:70..<90,value:10.0),(range:90..<500,value:30.0)]
    var incrementalValue:Double = 1.0
    
    //Internal varibles
    weak var delegate:BarcelonetaDelegate?
    private var percentage:Int = 100
    private var timer = NSTimer()
    private var elasticPanGesture:UIPanGestureRecognizer! = nil
    private weak var verticalConstraint:NSLayoutConstraint! = nil
    private var originalConstant : CGFloat = 0.0
    private var movesUp = true
    
    func makeVerticalElastic(verticalConstraint:NSLayoutConstraint, delegate: BarcelonetaDelegate){
        
//        print(incrementalSettings)
        
        self.delegate = delegate
        originalConstant = verticalConstraint.constant
        self.verticalConstraint = verticalConstraint
        if elasticPanGesture == nil {
            elasticPanGesture = UIPanGestureRecognizer(target: self, action: #selector(Barceloneta.panned(_:)))
            addGestureRecognizer(elasticPanGesture)
        }
    }
    
    func panned(sender: UIPanGestureRecognizer) {
        
        if(sender.state == .Began){
            timer = NSTimer.scheduledTimerWithTimeInterval(timerInterval, target: self, selector: #selector(Barceloneta.timerCalled), userInfo: nil, repeats: true);
        }
        
        let yTranslation = sender.translationInView(self).y
        
        //If ! movesUp, consider that the view moves down
        movesUp = yTranslation < 0
        
        
        //If the view is dragged beyond the verticalLimit (Up or down)
//        if yTranslation > verticalLimit || yTranslation < (verticalLimit * -1.0){
//            print("uo or down")
//            
//            verticalConstraint.constant = originalConstant + logConstraintValueForYPosition(yTranslation)
//        }
        
        
        //If the view is dragged beyond the verticalLimit (Up or down)
        //too low
        if yTranslation > verticalLimit {
            verticalConstraint.constant = originalConstant + logConstraintValueForYPosition(yTranslation)
        } //Too high
        else if yTranslation < (verticalLimit * -1.0){
            verticalConstraint.constant = originalConstant + ((logConstraintValueForYPosition(yTranslation * -1)) * -1)
        }
        else {
            verticalConstraint.constant = originalConstant + yTranslation
        }
        
        if(sender.state == UIGestureRecognizerState.Ended ){
            animateViewBackToOrigin()
            timer.invalidate()
        }
        
        let prct = Int(100.0 / (verticalLimit/verticalConstraint.constant))
        percentage = prct < 0 ? prct * -1 : prct
        //Find a setting matching the percentage
        let settings = incrementalSettings.filter({return $0.range ~= percentage})
        if settings.count == 1{
            //If a setting is found, the incremental value is applied
            incrementalValue = settings[0].value
        }
    }
    
    func timerCalled() {
        if movesUp {
            increment()
        }else{
            decrement()
        }
    }
    
    private func logConstraintValueForYPosition(yPosition : CGFloat) -> CGFloat {
        return verticalLimit * (1 + log10(yPosition/verticalLimit))
    }
    
    private func increment(){
        checkAndApply(value + incrementalValue)
    }
    
    private func decrement(){
        checkAndApply(value - incrementalValue)
    }
    
    func checkAndApply(newValue:Double){
    
        var checkedValue = value
        
        if newValue > maximumValue{
            checkedValue = loops ? minimumValue : maximumValue
        }
        else if newValue < minimumValue {
            checkedValue = loops ? maximumValue : minimumValue
        }
        else {
            checkedValue = newValue
        }
        
        if value != checkedValue {
            value = checkedValue
            delegate?.barcelonetaDidChangeValue(self, value: value)
        }
    }
    
    private func animateViewBackToOrigin() {
        
        verticalConstraint.constant = originalConstant
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 25, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            self.superview!.layoutIfNeeded()
            }, completion: nil)
        
        delegate?.barcelonetaDidRelease(self)
    }
}