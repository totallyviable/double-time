//
//  ViewController.swift
//  Double Time
//
//  Created by Jacob Bijani on 2/23/16.
//  Copyright © 2016 Totally Viable. All rights reserved.
//

import Foundation
import UIKit

class ViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var barAProgressLabel: UILabel!
    @IBOutlet weak var barBProgressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timerA.progressLabel = barAProgressLabel
        timerB.progressLabel = barBProgressLabel
        
        startGlobalTimer()
    }
    
    var globalTimer = NSTimer()
    var globalTimerSecondsElapsed = 0

    var timerA = Timer(length: 5)
    var timerB = Timer(length: 5)
    
    var activeTimer: Timer!
    
    func startGlobalTimer() {
        globalTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "globalTimerSelector", userInfo: nil, repeats: true)
        
        toggleActiveTimer()
        
        // prefill timers with full values
        updateText(timerA, seconds: timerA.length)
        updateText(timerB, seconds: timerB.length)
    }
    
    func globalTimerSelector() {
        globalTimerSecondsElapsed += 1
        
        if (globalTimerSecondsElapsed == activeTimer.length) {
            globalTimerSecondsElapsed = 0
            
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
    }
}

