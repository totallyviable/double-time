//
//  Timer.swift
//  Double Time
//
//  Created by Jacob Bijani on 2/23/16.
//  Copyright © 2016 Totally Viable. All rights reserved.
//

import UIKit
import AVFoundation

let prefs = NSUserDefaults.standardUserDefaults()

class Timer {
    // MARK: properties
    
    var name: String!
    var duration = 0
    
    var progressLabel: UILabel!
    var progressBar: UIImageView!
    var progressBarColor: UIColor!
    
    var doneSound: AVAudioPlayer?
    
    init(name: String) {
        self.name = name
        
        setupTimerForName(name)
    }
    
    // MARK: private
    
    private func setupTimerForName(name: String) {
        var durationDefault: Int
        
        switch name {
        case "top":
            durationDefault = 5
            self.progressBarColor = UIColor(red:0.92, green:0.26, blue:0.0, alpha:1.0)
        case "bottom":
            durationDefault = 3
            self.progressBarColor = UIColor(red:0.1, green:0.27, blue:0.74, alpha:1.0)
        default:
            print ("Invalid timer name '" + name);
            return
        }
        
        self.duration = (prefs.integerForKey(name + "TimerDuration") != 0) ? prefs.integerForKey(name + "TimerDuration") : durationDefault
        
        setupDoneSound("done-sound-" + name)
    }
    
    private func setupAudioPlayerWithFile(file: NSString, type: NSString) -> AVAudioPlayer?  {
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)
        
        var audioPlayer: AVAudioPlayer?
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
        } catch {
            print("Player not available")
        }
        
        return audioPlayer
    }
    
    private func setupDoneSound(audioFileName: String) {
        if let doneSound = self.setupAudioPlayerWithFile(audioFileName, type: "wav") {
            self.doneSound = doneSound
        }
    }
    
    // MARK: public
    
    func playDoneSound() {
        self.doneSound?.play()
    }
}

