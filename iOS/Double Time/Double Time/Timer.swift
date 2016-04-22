//
//  Timer.swift
//  Double Time
//
//  Created by Jacob Bijani on 2/23/16.
//  Copyright © 2016 Totally Viable. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

let prefs = NSUserDefaults.standardUserDefaults()

class AudioHelper: NSObject, AVAudioPlayerDelegate {
    var player: AVAudioPlayer?
    var playbackMode: AVAudioSessionCategoryOptions!
    
    var filename: String
    var filetype = "wav"
    
    init(filename: String) {
        self.filename = filename
    }
    
    init(filename: String, filetype: String) {
        self.filename = filename
        self.filetype = filetype
    }
    
    func setupAudioPlayerWithFile(filename: NSString, filetype: NSString) -> AVAudioPlayer?  {
        let path = NSBundle.mainBundle().pathForResource(filename as String, ofType: filetype as String)
        let url = NSURL.fileURLWithPath(path!)
        
        var audioPlayer: AVAudioPlayer?
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
        } catch {
            print("Player not available")
        }
        
        return audioPlayer
    }
    
    func initializeAudioPlayer(playbackMode: AVAudioSessionCategoryOptions = AVAudioSessionCategoryOptions.MixWithOthers) {
        self.playbackMode = playbackMode
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: self.playbackMode)
        } catch {
            print("Could not set playback options to DuckOthers")
        }
        
        self.player = setupAudioPlayerWithFile(self.filename, filetype: self.filetype)
        self.player!.delegate = self
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        print("Did finish playing: ", self.filename, ".", self.filetype)
        
        do {
//            try AVAudioSession.sharedInstance().setActive(false)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: AVAudioSessionCategoryOptions.MixWithOthers)
        } catch {
            print("AVAudioSession setActive(false) failed")
        }
    }
    
    func stop() {
        self.player?.stop()
        self.player?.prepareToPlay()
    }
    
    func play(numberOfLoops: Int = 0) {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: self.playbackMode)
        } catch {
            print("AVAudioSession setActive(true) failed")
        }
        
        self.player?.numberOfLoops = numberOfLoops
        self.player?.play()
    }
    
}

class Timer {
    // MARK: properties
    
    var name: String!
    var duration = 0
    var elapsedTime = 0
    
    var progressLabel: UILabel!
    var progressBar: UIImageView!
    var progressBarColor: UIColor!
    
    var doneSound: AudioHelper!
    
    static var textColorInactive = UIColor(red: 0.4, green: 0.384314, blue: 0.341176, alpha: 1.0)
    static var textColorActive = UIColor.whiteColor()
    
    init(name: String) {
        self.name = name
        
        self.setupTimerForName(name)
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
        
        self.doneSound = AudioHelper(filename: "done-sound-" + name)
        self.doneSound.initializeAudioPlayer(AVAudioSessionCategoryOptions.DuckOthers)
    }
}

