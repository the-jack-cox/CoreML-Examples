//
//  AdultIncome.swift
//  MLCore Examples
//
//  Created by Jack Cox on 6/9/18.
//  Copyright © 2018 CapTech Consulting. All rights reserved.
//

import Foundation
import CoreML

class AdultIncomeData  {
    
    var age:Double = 35
    var capitalGain:Double = 0.0
    var capitalLoss:Double = 0.0
    var hoursPerWeek:Double = 40.0
    
    
    var workClass:String = "Private"
    let workClassValues:[String] = ["Private", "Self-emp-not-inc", "Self-emp-inc", "Federal-gov", "Local-gov", "State-gov", "Without-pay", "Never-worked"].sorted()
    
    var education:String = "HS-grad"
    
    let educationValues:[String] = ["Bachelors", "Some-college", "11th", "HS-grad", "Prof-school", "Assoc-acdm", "Assoc-voc", "9th", "7th-8th", "12th", "Masters", "1st-4th", "10th", "Doctorate", "5th-6th", "Preschool"].sorted()
    
    var maritalStatus:String = "Never-married"
    
    let maritalStatusValues:[String] = ["Married-civ-spouse", "Divorced", "Never-married", "Separated", "Widowed", "Married-spouse-absent", "Married-AF-spouse"].sorted()
    
    var occupation:String = "Tech-support"
    let occupationValues:[String] = ["Tech-support", "Craft-repair", "Other-service", "Sales", "Exec-managerial", "Prof-specialty", "Handlers-cleaners", "Machine-op-inspct", "Adm-clerical", "Farming-fishing", "Transport-moving", "Priv-house-serv", "Protective-serv", "Armed-Forces"].sorted()
    
    var relationship:String = "Own-child"
    let relationshipValues:[String] = ["Wife", "Own-child", "Husband", "Not-in-family", "Other-relative", "Unmarried"].sorted()
 
    var race:String = "White"
    let raceValues:[String] = ["White", "Asian-Pac-Islander", "Amer-Indian-Eskimo", "Other", "Black"].sorted()
    
    var sex:String = "Male"
    let sexValues:[String] = ["Male", "Female"].sorted()
    
    var nativeCountry = "United-States"
    let nativeCountryValues:[String] = ["United-States", "Cambodia", "England", "Puerto-Rico", "Canada", "Germany", "Outlying-US(Guam-USVI-etc)", "India", "Japan", "Greece", "South", "China", "Cuba", "Iran", "Honduras", "Philippines", "Italy", "Poland", "Jamaica", "Vietnam", "Mexico", "Portugal", "Ireland", "France", "Dominican-Republic", "Laos", "Ecuador", "Taiwan", "Haiti", "Columbia", "Hungary", "Guatemala", "Nicaragua", "Scotland", "Thailand", "Yugoslavia", "El-Salvador", "Trinadad&Tobago", "Peru", "Hong", "Holand-Netherlands"].sorted()
}
