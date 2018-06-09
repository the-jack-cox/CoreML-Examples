import Foundation
import CreateML

let trainDirectory = URL(fileURLWithPath: "/Users/jcox/Downloads/256_ObjectCategories")

// train with all options for 30 iterations

let parameters = MLImageClassifier.ModelParameters(featureExtractor: .scenePrint(revision: 1), validationData: nil, maxIterations: 30, augmentationOptions: [])
let classifier = try MLImageClassifier(trainingData: .labeledDirectories(at: trainDirectory), parameters: parameters)

try classifier.write(to: URL(fileURLWithPath: "/Users/jcox/Desktop/ImageClassifier256.mlmodel"), metadata: MLModelMetadata(author: "Jack Cox", shortDescription: "Image Classification Model trained on the Caltech 256 image set", license: nil, version: "1.0", additional: nil))





