//
//  SecondViewController.swift
//  MLCore Examples
//
//  Created by Jack Cox on 6/9/18.
//  Copyright © 2018 CapTech Consulting. All rights reserved.
//

import UIKit

class MLTableDataViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    

    @IBOutlet weak var ageValueLabel: UILabel!
    @IBOutlet weak var ageSlider: UISlider!
    @IBOutlet weak var predictionLabel: UILabel!
    
    @IBOutlet var pickers: [UIPickerView]!
    
    @IBOutlet weak var workClassLabel: UILabel!
    @IBOutlet weak var workClassStack: UIStackView!
    @IBOutlet weak var workClassPicker: UIPickerView!
    
    @IBOutlet weak var educationStack: UIStackView!
    @IBOutlet weak var educationLabel: UILabel!
    @IBOutlet weak var educationPicker: UIPickerView!
    
    @IBOutlet weak var maritalStatusStack: UIStackView!
    @IBOutlet weak var maritalStatusLabel: UILabel!
    @IBOutlet weak var maritalStatusPicker: UIPickerView!
    
    @IBOutlet weak var occupationLabel: UILabel!
    @IBOutlet weak var occupationPicker: UIPickerView!
    
    @IBOutlet weak var relationshipLabel: UILabel!
    @IBOutlet weak var relationshipPicker: UIPickerView!
    
    @IBOutlet weak var raceLabel: UILabel!
    @IBOutlet weak var racePicker: UIPickerView!
    
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var sexPicker: UIPickerView!
    
    @IBOutlet weak var capitalGainLabel: UILabel!
    @IBOutlet weak var capitalGainSlider: UISlider!
    
    @IBOutlet weak var capitalLossLabel: UILabel!
    @IBOutlet weak var capitalLossSlider: UISlider!
    

    @IBOutlet weak var hoursSlider: UISlider!
    @IBOutlet weak var hoursLabel: UILabel!
    
    @IBOutlet weak var nativeCountryLabel: UILabel!
    @IBOutlet weak var nativeCountryPicker: UIPickerView!
    
    var adultData = AdultIncomeData()
    
    var model = AdultIncome()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetPickerValues()
    
        updateDisplayValues()
    }
    
    
    func predictIncomeLevel() {
        do {
            let prediction = try model.prediction(age: self.adultData.age,
                                                  work_class: self.adultData.workClass,
                                                  education: self.adultData.education,
                                                  marital_status: self.adultData.maritalStatus,
                                                  occupation: self.adultData.occupation,
                                                  relationship: self.adultData.relationship,
                                                  race: self.adultData.race,
                                                  sex: self.adultData.sex,
                                                  capital_gain: self.adultData.capitalGain,
                                                  capital_loss: self.adultData.capitalLoss,
                                                  hours_per_week: self.adultData.hoursPerWeek,
                                                  native_country: self.adultData.nativeCountry)
            
            // the property names are dependent up on the structure of the model
            let level = prediction.income_level
            // non-neural network models don't provide a probability
            let prob = prediction.income_levelProbability
            
            self.predictionLabel.text = String(format: "\(level) : %0.2f%%", prob)
        } catch {
            print("Error: infering income level")
        }
        
    }

    fileprivate func resetPickerValues() {
        
        // reset all picker values
        workClassPicker.selectRow(adultData.workClassValues.index(of: adultData.workClass) ?? 0, inComponent: 0, animated: false)
        educationPicker.selectRow(adultData.educationValues.index(of: adultData.education) ?? 0, inComponent: 0, animated: false)
        maritalStatusPicker.selectRow(adultData.maritalStatusValues.index(of: adultData.maritalStatus) ?? 0, inComponent: 0, animated: false)
        occupationPicker.selectRow(adultData.occupationValues.index(of: adultData.occupation) ?? 0, inComponent: 0, animated: false)
        relationshipPicker.selectRow(adultData.relationshipValues.index(of: adultData.relationship) ?? 0, inComponent: 0, animated: false)
        racePicker.selectRow(adultData.raceValues.index(of: adultData.race) ?? 0, inComponent: 0, animated: false)
        sexPicker.selectRow(adultData.sexValues.index(of: adultData.sex) ?? 0, inComponent: 0, animated: false)
        nativeCountryPicker.selectRow(adultData.nativeCountryValues.index(of: adultData.nativeCountry) ?? 0, inComponent: 0, animated: false)
    }
    func updateDisplayValues() {
        predictIncomeLevel()
        ageValueLabel.text = "\(self.adultData.age))"
        
        workClassLabel.text = adultData.workClass
        educationLabel.text = adultData.education
        maritalStatusLabel.text = adultData.maritalStatus
        occupationLabel.text = adultData.occupation
        relationshipLabel.text = adultData.relationship
        raceLabel.text = adultData.race
        sexLabel.text = adultData.sex
        
        capitalGainLabel.text = "\(adultData.capitalGain)"
        capitalLossLabel.text = "\(adultData.capitalLoss)"
        hoursLabel.text = "\(adultData.hoursPerWeek)"
        
        nativeCountryLabel.text = adultData.nativeCountry
        
        predictIncomeLevel()
    }
    // MARK: Handle Continuous Values
    @IBAction func ageSliderChanged(_ sender: UISlider) {
        self.adultData.age = Double(sender.value.rounded(.towardZero))
        self.updateDisplayValues()
    }
    @IBAction func capitalGainChanged(_ sender: UISlider) {
        self.adultData.capitalGain = Double(sender.value.rounded(.towardZero))
        self.updateDisplayValues()
    }
    
    @IBAction func capitalLossChanged(_ sender: UISlider) {
        self.adultData.capitalLoss = Double(sender.value.rounded(.towardZero))
        self.updateDisplayValues()
    }
    @IBAction func hoursChanged(_ sender: UISlider) {
        self.adultData.hoursPerWeek = Double(sender.value.rounded(.towardZero))
        self.updateDisplayValues()
    }
    
    // MARK: Handle Pickers
    
    private func closePickers() {
        pickers.forEach { (picker) in
            picker.isHidden = true
        }
    }
    @IBAction func workClassTapped(_ sender: Any) {
        let hidden = workClassPicker.isHidden
        closePickers()
        workClassPicker.isHidden = !hidden
    }
    
    @IBAction func educationTapped(_ sender: Any) {
        let hidden = educationPicker.isHidden
        closePickers()
        educationPicker.isHidden = !hidden
    }
    @IBAction func maritalStatusTapped(_ sender: Any) {
        let hidden = maritalStatusPicker.isHidden
        closePickers()
        maritalStatusPicker.isHidden = !hidden
    }
  
    @IBAction func occupationTapped(_ sender: Any) {
        let hidden = occupationPicker.isHidden
        closePickers()
        occupationPicker.isHidden = !hidden
    }
    @IBAction func relationshipTapped(_ sender: Any) {
        let hidden = relationshipPicker.isHidden
        closePickers()
        relationshipPicker.isHidden = !hidden
    }
    @IBAction func raceTapped(_ sender: Any) {
        let hidden = racePicker.isHidden
        closePickers()
        racePicker.isHidden = !hidden
    }
    @IBAction func sexTapped(_ sender: Any) {
        let hidden = sexPicker.isHidden
        closePickers()
        sexPicker.isHidden = !hidden
    }
    @IBAction func nativeCountryTapped(_ sender: Any) {
        let hidden = nativeCountryPicker.isHidden
        closePickers()
        nativeCountryPicker.isHidden = !hidden
    }

    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case workClassPicker:
            return self.adultData.workClassValues.count
        case educationPicker:
            return self.adultData.educationValues.count
        case maritalStatusPicker:
            return self.adultData.maritalStatusValues.count
        case occupationPicker:
            return self.adultData.occupationValues.count
        case relationshipPicker:
            return self.adultData.relationshipValues.count
        case racePicker:
            return self.adultData.raceValues.count
        case sexPicker:
            return self.adultData.sexValues.count
        case nativeCountryPicker:
            return self.adultData.nativeCountryValues.count
        default :
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch pickerView {
        case workClassPicker:
            return self.adultData.workClassValues[row]
        case educationPicker:
            return self.adultData.educationValues[row]
        case maritalStatusPicker:
            return self.adultData.maritalStatusValues[row]
        case occupationPicker:
            return self.adultData.occupationValues[row]
        case relationshipPicker:
            return self.adultData.relationshipValues[row]
        case racePicker:
            return self.adultData.raceValues[row]
        case sexPicker:
            return self.adultData.sexValues[row]
        case nativeCountryPicker:
            return self.adultData.nativeCountryValues[row]
        default :
            return nil
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case workClassPicker:
            self.adultData.workClass = self.adultData.workClassValues[row]
        case educationPicker:
            self.adultData.education = self.adultData.educationValues[row]
        case maritalStatusPicker:
            self.adultData.maritalStatus = self.adultData.maritalStatusValues[row]
        case occupationPicker:
            self.adultData.occupation = self.adultData.occupationValues[row]
        case relationshipPicker:
            self.adultData.relationship = self.adultData.relationshipValues[row]
        case racePicker:
            self.adultData.race = self.adultData.raceValues[row]
        case sexPicker:
            self.adultData.sex = self.adultData.sexValues[row]
        case nativeCountryPicker:
            self.adultData.nativeCountry = self.adultData.nativeCountryValues[row]
        default :
            break
        }

        self.updateDisplayValues()
    }


}

