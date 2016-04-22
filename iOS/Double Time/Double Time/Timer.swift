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
    
    var filename: String
    var filetype = "wav"
    
    init(filename: String) {
        self.filename = filename
    }
    
    init(filename: String, filetype: String) {
        self.filename = filename
        self.filetype = filetype
    }
    
    private func setupAudioPlayerWithFile(filename: NSString, filetype: NSString) -> AVAudioPlayer?  {
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
    
    func initializeAudioPlayer() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: AVAudioSessionCategoryOptions.DuckOthers)
        } catch {
            print("Could not set playback options to DuckOthers")
        }
        
        self.player = setupAudioPlayerWithFile(self.filename, filetype: self.filetype)
        self.player!.delegate = self
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        print("Did finish playing")
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("AVAudioSession setActive(false) failed")
        }
    }
    
    
    func stop() {
        self.player?.stop()
        self.player?.prepareToPlay()
    }
    
    func play() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AVAudioSession setActive(true) failed")
        }
        
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
    var localNotification: UILocalNotification?
    
    static var textColorInactive = UIColor(red: 0.4, green: 0.384314, blue: 0.341176, alpha: 1.0)
    static var textColorActive = UIColor.whiteColor()
    
    // MARK: public
    
    init(name: String) {
        self.name = name
        
        self.setupTimerForName(name)
    }
    
    func scheduleLocalNotification() {
        guard let settings = UIApplication.sharedApplication().currentUserNotificationSettings() else { return }
        
        if settings.types == .None {
            return
        }
        
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: Double(self.duration))
        notification.alertBody = "Timer over: " + self.name
        notification.soundName = "\(self.doneSound.filename).\(self.doneSound.filetype)"
        notification.userInfo = ["TimerName": self.name]
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        self.localNotification = notification
    }
    
    func removeLocalNotification() {
        guard let notification = self.localNotification else { return }
        
        UIApplication.sharedApplication().cancelLocalNotification(notification)
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
        self.doneSound.initializeAudioPlayer()
    }
}

