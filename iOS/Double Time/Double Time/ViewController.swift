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
        
        timerA.setProgressLabel(barAProgressLabel)
        timerB.setProgressLabel(barBProgressLabel)
        
        startGlobalTimer()
    }
    
    var globalTimer = NSTimer()
    var globalTimerSecondsElapsed = 0

    var timerA = Timer(length: 10)
    var timerB = Timer(length: 5)
    
    var activeTimer: Timer!
    
    func startGlobalTimer() {
        globalTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "globalTimerCountUp", userInfo: nil, repeats: true)
        
        activeTimer = timerA
    }
    
    func globalTimerCountUp() {
        globalTimerSecondsElapsed += 1
        
        if (globalTimerSecondsElapsed > activeTimer.length) {
            globalTimerSecondsElapsed = 1
            updateText(0)
            
            if (activeTimer === timerA) {
                activeTimer = timerB
            } else {
                activeTimer = timerA
            }
            
            globalTimerSecondsElapsed = 1
            updateText(1)
        }
        
        updateText(globalTimerSecondsElapsed)
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (String, String, String) {
        return (String(format: "%02d", seconds / 3600), String(format: "%02d", (seconds % 3600) / 60), String(format: "%02d", seconds % 60))
    }
    
    func updateText(seconds: Int) {
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds)
        
        activeTimer.progressLabel.text = "\(h):\(m):\(s)"
    }
}

