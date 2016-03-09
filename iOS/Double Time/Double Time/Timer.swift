//
//  Timer.swift
//  Double Time
//
//  Created by Jacob Bijani on 2/23/16.
//  Copyright © 2016 Totally Viable. All rights reserved.
//

import UIKit
import AVFoundation

class Timer {
    var length = 0
    
    var progressLabel: UILabel!
    var progressBar: UIImageView!
    var progressBarColor: UIColor!
    
    var doneSound: AVAudioPlayer?
    
    init(length: Int) {
        self.length = length
    }
    
    func setupAudioPlayerWithFile(file: NSString, type: NSString) -> AVAudioPlayer?  {
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
    
    func setupDoneSound(audioFileName: String) {
        if let doneSound = self.setupAudioPlayerWithFile(audioFileName, type: "wav") {
            self.doneSound = doneSound
        }
    }
    
    func playDoneSound() {
        self.doneSound?.play()
    }
}

