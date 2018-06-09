//
//  SettingsViewController.swift
//  MLCore Examples
//
//  Created by Jack Cox on 6/9/18.
//  Copyright © 2018 CapTech Consulting. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var gpuSwitch: UISwitch!
    @IBOutlet weak var customClassificationSwitch: UISwitch!
    @IBOutlet weak var inceptionClassificationSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        gpuSwitch.isOn = SettingsManager.sharedInstance.useGPUForImageClassification
        
        customClassificationSwitch.isOn = SettingsManager.sharedInstance.doCustomClassification
        
        inceptionClassificationSwitch.isOn = SettingsManager.sharedInstance.doInceptionClassification
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func gpuSwitchChanged(_ sender: UISwitch) {
        SettingsManager.sharedInstance.useGPUForImageClassification = sender.isOn
        
        
    }
    @IBAction func customClassificationChanged(_ sender: UISwitch) {
        SettingsManager.sharedInstance.doCustomClassification = sender.isOn
    }
    
    @IBAction func inceptionClassificationchanged(_ sender: UISwitch) {
        SettingsManager.sharedInstance.doInceptionClassification = sender.isOn
    }
}
