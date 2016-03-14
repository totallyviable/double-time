//
//  ViewController.swift
//  Double Time
//
//  Created by Jacob Bijani on 2/23/16.
//  Copyright © 2016 Totally Viable. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var barAProgressLabel: UILabel!
    @IBOutlet weak var barBProgressLabel: UILabel!
        
    @IBOutlet weak var barAProgressBar: UIImageView!
    @IBOutlet weak var barBProgressBar: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timerA.progressLabel = barAProgressLabel
        timerB.progressLabel = barBProgressLabel
        
        timerA.progressBar = barAProgressBar
        timerB.progressBar = barBProgressBar
        
        timerA.progressBarColor = UIColor(red:0.92, green:0.26, blue:0.0, alpha:1.0)
        timerB.progressBarColor = UIColor(red:0.1, green:0.27, blue:0.74, alpha:1.0)
        
        drawProgressBar(timerA)
        drawProgressBar(timerB)
        
        timerA.setupDoneSound("doubletime-timer-a")
        timerB.setupDoneSound("doubletime-timer-b")
        
        startGlobalTimer()
    }
    
    @IBAction func handleBarALongPress(sender: AnyObject) {
        if sender.state == UIGestureRecognizerState.Began {
            openSetDurationPrompt(timerA)
        }
    }
    
    @IBAction func handleBarBLongPress(sender: AnyObject) {
        if sender.state == UIGestureRecognizerState.Began {
            openSetDurationPrompt(timerB)
        }
    }
    
    func openSetDurationPrompt(timer: Timer) {
        stopGlobalTimer()
        
        let alertController = UIAlertController(title: nil, message: "Set duration", preferredStyle: .Alert)
        
        let setDurationAction = UIAlertAction(title: "Set Duration", style: .Default) { (_) in
            let durationTextField = alertController.textFields![0] as UITextField
            
            self.setDuration(timer, duration: durationTextField.text! as String)
        }
        
        setDurationAction.enabled = false
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in
            self.startGlobalTimer()
        }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = String(timer.length)
            textField.keyboardType = .NumberPad
            
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                setDurationAction.enabled = textField.text != ""
            }
        }
        
        alertController.addAction(setDurationAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func setDuration(timer: Timer, duration: String) {
        timer.length = Int(duration)!
        
        activeTimer = nil
        
        self.startGlobalTimer()
    }
    
    func drawProgressBar(timer: Timer) {
        let imageView = timer.progressBar
        
        let rect = CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)
        
        UIGraphicsBeginImageContextWithOptions(imageView.frame.size, false, 0)
        
        timer.progressBarColor.setFill()
        UIRectFill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        imageView.image = image
        
        resetProgressBar(imageView)
    }
    
    func animateProgressBar(imageView: UIImageView, duration: Double) {
        resetProgressBar(imageView)
        
        UIView.animateWithDuration(duration, animations:
            {() -> Void in
                imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, imageView.superview!.frame.width, imageView.frame.height)
            })
            { (finished) -> Void in
                UIView.animateWithDuration(0.3, animations:
                    {() -> Void in
                        imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, 0, imageView.frame.height)
                    })
                    { (finished) -> Void in
                        self.resetProgressBar(imageView)
                }
        }
    }
    
    func resetProgressBar(imageView: UIImageView) {
        imageView.layer.removeAllAnimations()
        
        imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, 0.0, imageView.frame.height)
    }
    
    var globalTimer = NSTimer()
    var globalTimerSecondsElapsed = 0

    var timerA = Timer(length: 3)
    var timerB = Timer(length: 5)
    
    var activeTimer: Timer!
    
    func startGlobalTimer() {
        globalTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "globalTimerSelector", userInfo: nil, repeats: true)
        
        toggleActiveTimer()
        
        // prefill timers with full values
        updateText(timerA, seconds: timerA.length)
        updateText(timerB, seconds: timerB.length)
    }
    
    func stopGlobalTimer() {
        globalTimer.invalidate()
        globalTimerSecondsElapsed = 0
        
        resetProgressBar(timerA.progressBar)
        resetProgressBar(timerB.progressBar)
    }
    
    func globalTimerSelector() {
        globalTimerSecondsElapsed += 1
        
        if (globalTimerSecondsElapsed == activeTimer.length) {
            globalTimerSecondsElapsed = 0
            
            activeTimer.playDoneSound()
            
            resetTimer(activeTimer)
            
            toggleActiveTimer()
        }
        
        updateText(activeTimer, seconds: activeTimer.length - globalTimerSecondsElapsed)
    }
    
    func secondsToHoursMinutesSeconds(seconds: Int) -> (String, String, String) {
        return (String(format: "%02d", seconds / 3600), String(format: "%02d", (seconds % 3600) / 60), String(format: "%02d", seconds % 60))
    }
    
    func updateText(timer: Timer, seconds: Int) {
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds)
        
        timer.progressLabel.text = "\(h):\(m):\(s)"
    }
    
    var resetTimerInterval = NSTimer()
    var resetTimerActiveTimer: Timer!
    var resetTimerCount = 0.0
    
    func resetTimer(timer: Timer) {
        resetTimerCount = 0.0
        
        resetTimerActiveTimer = timer
        
        updateText(resetTimerActiveTimer, seconds: 0)
        
        resetTimerInterval = NSTimer.scheduledTimerWithTimeInterval(1.0 / 60.0, target: self, selector: "resetTimerSelector", userInfo: nil, repeats: true)
    }
    
    func resetTimerSelector() {
        resetTimerCount += ceil(Double(resetTimerActiveTimer.length) / 60.0)
        
        updateText(resetTimerActiveTimer, seconds: Int(resetTimerCount))
        
        if (resetTimerCount >= Double(resetTimerActiveTimer.length)) {
            resetTimerInterval.invalidate()
        }
    }
    
    func toggleActiveTimer() {
        // if it's nil, "start" with B so that we immediately switch to A
        if (activeTimer == nil) {
            activeTimer = timerB
        }
        
        activeTimer.progressLabel.textColor = UIColor(red: 0.4, green: 0.384314, blue: 0.341176, alpha: 1.0)
        
        if (activeTimer === timerA) {
            activeTimer = timerB
        } else {
            activeTimer = timerA
        }
        
        activeTimer.progressLabel.textColor = UIColor.whiteColor()
        
        animateProgressBar(activeTimer.progressBar, duration: Double(activeTimer.length))
    }
}

