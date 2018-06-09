import Foundation
import CreateMLUI
import CreateML
import XCPlayground

// make sure we can find the csv file
guard let trainingCSV = Bundle.main.url(forResource: "adult-income", withExtension: "csv") else {
    fatalError()
}


// load the CSV file into a data table
var adultData = try MLDataTable(contentsOf: trainingCSV)

// remove columns that are don't have individual value or are duplicative
adultData.removeColumn(named: "fnlwgt")
adultData.removeColumn(named: "education-num")

// do the train/test split
let (trainingData,testData) = adultData.randomSplit(by: 0.8, seed: 0)

// create the classifier
let predictor = try MLClassifier(trainingData: trainingData, targetColumn: "income-level")

// evaluate it
let metrics = predictor.evaluation(on: testData)

print(metrics)

// save the model in the local desktop
// TODO: change the path to where you want it, unless your username is jcox
var outputURL = URL(fileURLWithPath: "/Users/jcox/Desktop/AdultIncome.mlmodel")
var modelMetadata = MLModelMetadata(author: "Jack Cox", shortDescription: "Classifier from UCI Adult Income dataset https://archive.ics.uci.edu/ml/datasets/Adult", license: nil, version: "1.0", additional: nil)
try predictor.write(to: outputURL, metadata: modelMetadata)

// Do a test evaluation

// 35, Self-emp-inc, 182148, Bachelors, 13, Married-civ-spouse, Exec-managerial, Husband, White, Male, 0, 0, 60, United-States, >50K
//age, work class, fnlwgt, education, education-num, marital-status, occupation, relationship, race, sex, capital-gain, capital-loss, hours-per-week, native-country, income-level
let p1 = try MLDataTable(dictionary: ["age" : 35, "work class":"Self-emp-inc",
                                      "education": "Bachelors",
                                      "marital-status":"Married-civ-spouse",
                                      "occupation":"Exec-managerial",
                                      "relationship":"Husband",
                                      "race":"White",
                                      "sex": 0,
                                      "capital-gain":0,
                                      "capital-loss":60,
                                      "hours-per-week":60,
                                      "native-country":"United-States"
    ])


let predictions = try predictor.predictions(from: p1)

predictions
print(predictions)




