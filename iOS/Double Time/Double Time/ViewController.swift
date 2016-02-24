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
        
        startGlobalTimer()
    }
    
    var globalTimer = NSTimer()
    var globalTimerSecondsElapsed = 0

    var timerATime = 5
    var timerBTime = 3
    
    func startGlobalTimer() {
        globalTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "globalTimerCountUp", userInfo: nil, repeats: true)
    }
    
    func globalTimerCountUp() {
        globalTimerSecondsElapsed += 1
        
        if (globalTimerSecondsElapsed == 5) {
//            globalTimerSecondsElapsed = 0
        }
        
        updateText()
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (String, String, String) {
        return (String(format: "%02d", seconds / 3600), String(format: "%02d", (seconds % 3600) / 60), String(format: "%02d", seconds % 60))
    }
    
    func updateText() {
        let (h,m,s) = secondsToHoursMinutesSeconds(globalTimerSecondsElapsed)
        
        barAProgressLabel.text = "\(h):\(m):\(s)"
    }
}

