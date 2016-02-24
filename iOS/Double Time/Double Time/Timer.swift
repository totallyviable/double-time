//
//  Timer.swift
//  Double Time
//
//  Created by Jacob Bijani on 2/23/16.
//  Copyright © 2016 Totally Viable. All rights reserved.
//

import UIKit

class Timer {
    var length = 0
    var currentTime: Int?
    
    var progressLabel: UILabel!
    
    init(length: Int) {
        self.length = length
        self.currentTime = 0
    }
    
    func setProgressLabel(progressLabel: UILabel) {
        self.progressLabel = progressLabel
    }
}

