//
//  SelfClearingLabel.swift
//  MLCore Examples
//
//  Created by Jack Cox on 6/9/18.
//  Copyright © 2018 CapTech Consulting. All rights reserved.
//

import UIKit

class SelfClearingLabel:UILabel {
    
    var clearTimer:Timer?
    
    @IBInspectable var secondsToClear:Double = 5.0
        
    override var text:String? {
        didSet {
            clearTimer?.invalidate()
            if let t = self.text, t.count > 0 {
                clearTimer = Timer.scheduledTimer(withTimeInterval: self.secondsToClear, repeats: false, block: { (timer) in
                    self.text = ""
                })
            }
            print("did set self clearing label to value: \(String(describing: self.text))")
        }
    }
    
    
}
