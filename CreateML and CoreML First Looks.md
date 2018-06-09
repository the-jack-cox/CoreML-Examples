# CreateML and CoreML First Looks

At WWDC 2018, Apple announced CoreML 2 and CreateML. CoreML 2 is focused on optimizations on model size, model performance, and model flexibility. CreateML is a new library designed for Swift playgrounds that allows data scientists to create models for iOS.  

This blog article summarizes my weekend with CreateML and CoreML to create a simple app that uses machine learning for two different actions: a) identifying objects in images in real time, b) predict someones income level based on demographic information. 

Before I dive into code I'm going to summarize my impressions and findings.

## Lessons Learned

1. Creating models using CreateML is vastly easier than creating models using TensorFlow or scikit-learn. I already had a few sets of data from prior experimentation with TensorFlow, I was able to learn the CreateML environment (despite the incomplete documentation in Xcode 10 beta 1), load the data for 2 data sets and train two models in under 1 hour. I think it's a great tool to start expirementing with machine learning.
2. Although CreateML is much easier to get started, it does lack the flexibility of the other machine learning tools like TensorFlow. For example, with TensorFlow I can create a neural network to build a regression model. With CreateML I'm limited to boosted tree, decision tree, linear, and random forest regressions; no neurons to be had for my regression.  The same is true for classification models, except for image classification.
3. The model size optimizations for image classification is phenomenal. I was able to train a model with 30,000 images ([CalTech 256 image set](http://www.vision.caltech.edu/Image_Datasets/Caltech256/)) and the resulting model is 4.2Mb. A similar InceptionV3 based model would be well over 100Mb.  The transfer learning and quantization applied by CreateML appears to perform magic. 
4. The model performance optimizations are also very good. Below is a performance graph of the iOS app showing CPU utilization (the models were restricted to running on the CPU only). The older InceptionV3 consumed vastly more CPU than the CreateML created model ![Performance Graph](https://github.com/jack-cox-captech/CoreML-Examples/raw/master/ClassificationPerformance.png) 
5. CreateML models may not work on older devices. Because of the transfer learning used to optimize the model, these smaller models probably won't work on older iOS version. [This thread](https://forums.developer.apple.com/thread/103969) on Apple's developer forums describes the reasons for the lack of backwards compatibility.
6. CreateML provides a new structure called a MLDataTable to simplify the loading and processing of large amounts of text and tabular data. I suspect that MLDataTable is based on the [Pandas](http://pandas.pydata.org) because some of the error messages I received are very close to identical to Pandas messages.  MLDataTable is very capable, except I couldn't figure out how to modify individual values that had been read from a data source.  For example, I wanted to convert a column that was floating point to a string column and I could not figure out how to do that without falling back to traditional Swift code.
7. Because of this limitation in MLDataTable, I think that most data scientists will need to also be proficient in Python, Jupyter Notebook, scikit-learn, Pandas, etc. in addition to CreateML. I don't think CreateML is a professional data science tool, yet.
8. Given the dramatic performance and size optimizations; I recomment using CreateML to generate the models for iOS apps if possible. 


## Code!

Now for looking at the CreateML playgrounds and code I wrote during this weekend of hacking.

### App Summary

The app I wrote does two very different machine learning functions: 

1. Classifies images in real time
2. Classifies numeric and text data

The image classification leverages ARKit to capture frames from the camera which are then passed to one or two models for classification.  The user can decide which models are used and whether to allow CoreML to use the GPU to perform the inference. The app has two models bundled in it: a) the standard InceptionV3 model, b) a custom model.  The custom model was trained on images from the [CalTech 256 image set](http://www.vision.caltech.edu/Image_Datasets/Caltech256/)

The numeric/text data classification uses a custom classifier model to predict the income level for an adult based on some demographic data. The data for the model came from [https://archive.ics.uci.edu/ml/datasets/Adult](https://archive.ics.uci.edu/ml/datasets/Adult). The data was collected in the 1994 census. When training the model I had to eliminate a handful of rows due to missing data.

### Image Classification Model Training

```swift
import Foundation
import CreateML

let trainDirectory = URL(fileURLWithPath: "/Users/jcox/Downloads/256_ObjectCategories")

// train with all options for 30 iterations

let parameters = MLImageClassifier.ModelParameters(featureExtractor: .scenePrint(revision: 1), validationData: nil, maxIterations: 30, augmentationOptions: [])
let classifier = try MLImageClassifier(trainingData: .labeledDirectories(at: trainDirectory), parameters: parameters)

try classifier.write(to: URL(fileURLWithPath: "/Users/jcox/Desktop/ImageClassifier256.mlmodel"), metadata: MLModelMetadata(author: "Jack Cox", shortDescription: "Image Classification Model trained on the Caltech 256 image set", license: nil, version: "1.0", additional: nil))

```



