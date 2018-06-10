# CreateML and CoreML First Look

At WWDC 2018, Apple announced CoreML 2 and CreateML. CoreML 2 is focused on optimizations on model size, model performance, and model flexibility. CreateML is a new library designed for Swift playgrounds that allows data scientists to create models for iOS.  

This blog article summarizes my weekend with CreateML and CoreML to create a simple app that uses machine learning for two different actions: a) identifying objects in images in real time, b) predict someones income level based on demographic information. 

Before I dive into code I'm going to summarize my impressions and findings.

## Lessons Learned

1. Creating models using CreateML is vastly easier than creating models using TensorFlow or scikit-learn. I already had a few sets of data from prior experimentation with TensorFlow, I was able to learn the CreateML environment (despite the incomplete documentation in Xcode 10 beta 1), load the data for 2 data sets and train two models in under 1 hour. I think it's a great tool to start experimenting with machine learning.
2. Although CreateML is much easier to get started, it does lack the flexibility of the other machine learning tools like TensorFlow. For example, with TensorFlow I can create a neural network to build a regression model. With CreateML I'm limited to boosted tree, decision tree, linear, and random forest regressions; no neurons to be had for my regression.  The same is true for classification models, except for image classification.
3. I think the safety-first mentality of Swift runs counter to the "poke it and see"™ nature of data science experimentation.  Python is well suited to experimentation since it doesn't enforce many type-safety rules or other strictures required for safe mobile development. I think this tension between safety and experimentation will slow Swift's adoption as a data science language.
3. The model size optimizations for image classification are phenomenal. I was able to train a model with 30,000 images ([CalTech 256 image set](http://www.vision.caltech.edu/Image_Datasets/Caltech256/)) and the resulting model is 4.2Mb. A similar InceptionV3 based model would be well over 100Mb.  The transfer learning and quantization applied by CreateML appears to perform magic. 
4. The model performance optimizations are also very good. Below is a performance graph of the iOS app showing CPU utilization (the models were restricted to running on the CPU only). The older InceptionV3 consumed vastly more CPU than the CreateML created model ![Performance Graph](https://github.com/jack-cox-captech/CoreML-Examples/raw/master/images/ClassificationPerformance.png) 
5. CreateML models may not work on older devices. Because of the transfer learning used to optimize the model, these smaller models probably won't work on older iOS versions. [This thread](https://forums.developer.apple.com/thread/103969) on Apple's developer forums describes the reasons for the lack of backwards compatibility.
6. CreateML provides a new structure called a MLDataTable to simplify the loading and processing of large amounts of text and tabular data. I suspect that MLDataTable is based on the [Pandas 🐼 framework](http://pandas.pydata.org) because some of the error messages I received are essentially to identical to Pandas messages.  MLDataTable is very capable, except I couldn't figure out how to modify individual values that had been read from a data source.  For example, I wanted to convert a column that was floating point to a string column and I could not figure out how to do that without falling back to traditional Swift code. This is probably because MLDataTable is a lazy-load data table which conflicts with the desire to perform batch modifications.
7. Because of this limitation in MLDataTable, I think that most data scientists will need to also be proficient in Python, Jupyter Notebook, scikit-learn, Pandas, etc. in addition to CreateML.
8. Given the dramatic performance and size optimizations; I recommend using CreateML to generate the models for iOS apps if at all possible. 


## Code!

Now on to looking at the CreateML playgrounds and code I wrote during this weekend of hacking. The code and playgrounds can be found on github at [https://github.com/jack-cox-captech/CoreML-Examples](https://github.com/jack-cox-captech/CoreML-Examples).

### App Summary

The app I wrote does two very different machine learning functions: 

1. Classifies images in real time
2. Classifies numeric and text data

The image classification leverages ARKit to capture frames from the camera which are then passed to one or two models for classification.  The user can decide which models are used and whether to allow CoreML to use the GPU to perform the inference. The app has two image classification models bundled in it: a) the standard InceptionV3 model, b) a custom model.  The custom model was trained on images from the [CalTech 256 image set](http://www.vision.caltech.edu/Image_Datasets/Caltech256/)

The numeric/text data classification uses a custom classifier model to predict the income level for an adult based on some demographic data. The data for the model came from [https://archive.ics.uci.edu/ml/datasets/Adult](https://archive.ics.uci.edu/ml/datasets/Adult). The data was collected in the 1994 census. When training the model I had to eliminate a handful of rows due to missing data.

### Image Classification Model Training

The playground to train the model for image classification is very simple. Due to the large number of images in the CalTech data set, the model takes about 3 hours to train on a 2015 MacBook Pro

```swift
import Foundation
import CreateML

// identify the training data
let trainDirectory = URL(fileURLWithPath: "/Users/jcox/Downloads/256_ObjectCategories")

// train with no options for 30 iterations
let parameters = MLImageClassifier.ModelParameters(featureExtractor: .scenePrint(revision: 1),
                                                   validationData: nil,
                                                   maxIterations: 30,
                                                   augmentationOptions: [])
let classifier = try MLImageClassifier(trainingData: .labeledDirectories(at: trainDirectory),
                                       parameters: parameters)
// wait about 2 hours

// save the model
try classifier.write(to: URL(fileURLWithPath: "/Users/jcox/Desktop/ImageClassifier256.mlmodel"),
                     metadata: MLModelMetadata(author: "Jack Cox",
                                               shortDescription: "Image Classification Model trained on the Caltech 256 image set",
                                               license: nil,
                                               version: "1.0",
                                               additional: nil))
```

There are a number of augmentation options that may be performed to improve the training by applying distortions and filters to the images to increase the variety of data fed to the training algorithm.  Some of the options failed on the CalTech data set. I didn't have time to diagnose why, so use those with caution. Adding iterations and augmentation options increases the training time.

The training uses two distinct steps. The first step, feature extraction, uses the GPU heavily. The second step, training, or as Apple calls it, calibrating the solver, uses the CPU heavily. 

In my work, I did not split out a set of evaluation images. Because of this, CreateML randomly pulled out 5% of the images as validation data.

The swift code above will work as a standalone Swift application suitable for running in a CI/CD pipeline.

### Tabular Data Classification Training

The playground to train the tabular data model is a bit more complex. I'm going to break it into smaller pieces and walk through it.

```swift
import Foundation
import CreateMLUI
import CreateML

// make sure we can find the csv file
guard let trainingCSV = Bundle.main.url(forResource: "adult-income", withExtension: "csv") else {
    fatalError()
}


// load the CSV file into a data table
var adultData = try MLDataTable(contentsOf: trainingCSV)

```

Following the standard imports, the code makes a URL pointing to the CSV file in the playground. If that file cannot be found the playground terminates.

Once the URL is created, we create an MLDataTable referencing the CSV file. The contents of the MLDataTable are lazily loaded, saving memory.

A couple lines from the CSV file are shown below.

```
age, work class, fnlwgt, education, education-num, marital-status, occupation, relationship, race, sex, capital-gain, capital-loss, hours-per-week, native-country, income-level
49, Private, 160187, 9th, 5, Married-spouse-absent, Other-service, Not-in-family, Black, Female, 0, 0, 16, Jamaica, <=50K
52, Self-emp-not-inc, 209642, HS-grad, 9, Married-civ-spouse, Exec-managerial, Husband, White, Male, 0, 0, 45, United-States, >50K
```

MLDataTable uses the first line of the CSV to identify the column names. It also examines the columns to determine the data types. The last column, income-level, is the label data that the model will predict when provided the other values.

CreateML will determine the best way to convert the text columns into numeric values to feed to the training engine; you don't need to figure that out yourself.

The next snippet refines the data and splits the data into training and test data.

```swift
// remove columns that are don't have individual value or are duplicative
adultData.removeColumn(named: "fnlwgt")
adultData.removeColumn(named: "education-num")

// do the train/test split
let (trainingData,testData) = adultData.randomSplit(by: 0.8, seed: 0)
```
The first column I removed, "fnlwgt", is a piece of data from the census that indicates how many people in the U.S. probably match the values found in that row. While interesting, it is not germane to making a prediction. The second column, "education-num", has a high correlation to the "education" column. I felt that including both would bias the model toward weighting education to heavily.

Lastly, this snippet splits the MLDataTable into two tables, ```trainingData``` and ```testData```, with an 80/20 split. 

Next, I create the classifier and evaluate it's performance against the test data, which is hasn't seen before the evaluation.

```swift
// create the classifier
let predictor = try MLClassifier(trainingData: trainingData, targetColumn: "income-level")

// evaluate it
let metrics = predictor.evaluation(on: testData)

print(metrics)
```
 
Because I use an MLClassifier, CreateML tries all of the classifiers in it's library and chooses the one with the best performance.  It's not clear how it decides which one is best.  Also, using the MLClassifier to try all the algorithms, I lose the ability to tune any of the classifiers to improve their performance.  You can manually create and train models based off of the other classifiers provided by CoreML.

Some of the classifiers are sensitive to missing data. So, I had to go back and remove a hand full of rows that had missing values. In a real-world scenario I would have had to either hand select a classifier that wasn't sensitive to gaps in the data or I would need to fill those gaps manually before I created the MLDataTable.

When training the classifiers, the playground displays lots of information in the playground console such as training and validation accuracy, and loss metrics.  

Below is a sample of the output:

```
Random forest classifier:
--------------------------------------------------------
Number of examples          : 37132
Number of classes           : 2
Number of feature columns   : 12
Number of unpacked features : 12
+-----------+--------------+-------------------+---------------------+-------------------+---------------------+
| Iteration | Elapsed Time | Training-accuracy | Validation-accuracy | Training-log_loss | Validation-log_loss |
+-----------+--------------+-------------------+---------------------+-------------------+---------------------+
| 1         | 0.020312     | 0.853038          | 0.848454            | 0.376084          | 0.384388            |
| 2         | 0.042169     | 0.853549          | 0.849975            | 0.381751          | 0.387875            |
| 3         | 0.063068     | 0.855866          | 0.852002            | 0.371977          | 0.380670            |
| 4         | 0.082911     | 0.859420          | 0.854029            | 0.369531          | 0.379687            |
| 5         | 0.103017     | 0.855946          | 0.853523            | 0.369995          | 0.381087            |
| 10        | 0.209920     | 0.856135          | 0.851495            | 0.369045          | 0.379132            |
+-----------+--------------+-------------------+---------------------+-------------------+---------------------+
```

The default number of iterations when using the MLClassifier is 10.  I wish I could change that without bypassing the helpfulness of the umbrella classifier.

After I trained the model I dumped out the metrics to see what those look like for the selected classifier.

```
----------------------------------
Number of examples: 9737
Number of classes: 2
Accuracy: 85.91%

******CONFUSION MATRIX******
----------------------------------
True\Pred <=50K  >50K   
<=50K     7012   379    
>50K      993    1353   

******PRECISION RECALL******
----------------------------------
Class Precision(%)   Recall(%)      
<=50K 87.60          94.87          
>50K  78.12          57.67   

```

The metrics for a classifier give you the [confusion matrics](https://en.wikipedia.org/wiki/Confusion_matrix) and precision/recall stats for the model. These values are available in the metrics objects as MLDataTables if you want to normalize the values.

The last thing of note in this playground is saving the model.

```swift
// save the model in the local desktop
// TODO: change the path to where you want it, unless your username is jcox
var outputURL = URL(fileURLWithPath: "/Users/jcox/Desktop/AdultIncome.mlmodel")
var modelMetadata = MLModelMetadata(author: "Jack Cox",
                                    shortDescription: "Classifier from UCI Adult Income dataset https://archive.ics.uci.edu/ml/datasets/Adult",
                                    license: nil,
                                    version: "1.0",
                                    additional: nil)
try predictor.write(to: outputURL, metadata: modelMetadata)
```

### Using the Image Classifier

In the associated project found at [https://github.com/jack-cox-captech/CoreML-Examples](https://github.com/jack-cox-captech/CoreML-Examples) all the code to classify the images is in the ```ARMLVisionViewController``` class.

The view controller uses some settings stored in the ```SettingsManager``` class. These settings are not persisted since the app is just a proof-of-concept.  

Loading the classifier models is best done once, especially the Inception model which is around 100Mb in size.

```swift
// the models to use for the classification
private lazy var customClassifierModel = ImageClassifier256().model
private lazy var inceptionClassiferModel = Inceptionv3().model
```

I used ARKit in this proof-of-concept because it was the quickest solution to grab frames for classification. If it were a real app, I would take the time to use ```AVCaptureSession``` and related classes to capture the video frames. This would give the image classifier more access to the GPU since it would not be shared with ARKit. When running two models on the CPU, and ARKit on the GPU, my iPhone X turns into a hand warmer.

The ```processClassifications``` method gets called after each image classification by each model. In other words, twice for each frame. Once for the custom model and once for the inception model.

```swift
// Show a label for the highest-confidence result (but only above a minimum confidence threshold).
if let bestResult = classifications.first(where: { result in result.confidence > 0.5 }),
    let clazz = bestResult.identifier.split(separator: ",").first {
    let confidence = bestResult.confidence
    message = String(format: "\(clazz) : %.2f", confidence * 100) + "% confidence"
    DispatchQueue.main.async {
         label.text = message
    }
}
```
The classification results don't come back on the main thread. So updating the UI must be dispatched to it.  In this proof-of-concept, I'm only displaying the best result that is above 50% confidence.


### Using the tabular data classifier

In the same project the code to classify tabular data is in the ```MLTableDataViewController``` class.  Unfortunately, most of the class is taken up with managing input on the form where the user can select the data that goes into the prediction. Actually, developing the form was, by far, the largest amount of work in this part of the app. There are 12 different data values to feed into the income level prediction. 

I created a helper class ```AdultIncomeData``` to hold the input values and the allowed values for the text fields.  

All of the models used in the app are included in the Xcode project.  
![Model List](https://github.com/jack-cox-captech/CoreML-Examples/raw/master/images/ProjectModelsScreenshot.png)

It is possible to load models from external sources so that they are not bundled in the app or so that you can update the model without having to redistribute new versions of the app. See [this blog](https://blog.zedge.net/developers-blog/hotswapping-machine-learning-models-in-coreml-for-iphone) for information on hot swapping models.

When bundled with the app, Xcode provides a nice view into the inputs and outputs of the model.
![Model Metadata](https://github.com/jack-cox-captech/CoreML-Examples/raw/master/images/AdultIncomeModelMetadataScreenshot.png)

This metadata can be helpful to see what the input and output values need to be when you're calling it for a prediction, as shown below.

```swift
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
let _ = prediction.income_levelProbability

```

The ```prediction``` method of the model helpfully provides placeholders for all of the parameters you need to make a prediction.  In this case, I'm pulling those values from the ```AdultIncomeData`` object.  

The output of the ```prediction``` method is an output object that includes the predicted output and a probability. In the case of the non-neural network models, the probability is always 0.

## Conclusion

CoreML 2 provides some very powerful optimizations for producing models that don't blow up your app size, and powerful processor optimization to make using machine learning in your app less harmful to battery life on the phone. While, not yet a production ready data science tool, in my opinion, CreateML should be studied as a possible way to produce the models for your iOS apps.  




