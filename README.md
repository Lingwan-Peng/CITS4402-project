# CITS4402-project SVM Classification Model

For the step five of this project we are required to apply a Support Vector Machine (SVM) to classify the extracted features into categories of Low-Grade Gliomas (LGG) and High-Grade Gliomas (HGG). This classification task involves the extraction of relevant features from MRI scans, addressing class imbalance, and evaluating the effectiveness of the SVM classifier.

## Data Partition

To train and validate the SVM classifier, the dataset was divided into a training set, a validation set, and a hidden testing set. Specifically:

- 10 LGG patients and 10 HGG patients were assigned to the hidden testing set.
- The remaining dataset was used for training and validation, either through a fixed data split or using cross-validation to ensure robust model evaluation.
- Class imbalance between LGG and HGG patients was addressed using oversampling, undersampling, or synthetic data generation techniques.

## Features used for training

The features used for training the SVM classifier were extracted from the MRI scans and included intensity, shape, and texture features. These features were selected based on their relevance to distinguishing between LGG and HGG. Feature selection was performed to identify the most discriminative features, and these were used to train the SVM classifier.

## Accuracy of model in classifying the MRI images during training, validation, and testing

The effectiveness of the SVM classifier was evaluated based on its accuracy during training, validation, and testing phases. The accuracy was calculated as follows:

$$
\text{Accuracy} = \frac{\text{Number of correct classifications}}{\text{Total number of classifications}}
$$

- **Training Accuracy**: The accuracy of the SVM classifier on the training set, indicating how well the model learned from the training data.
- **Validation Accuracy**: The accuracy on the validation set, used to tune hyperparameters and prevent overfitting.
- **Testing Accuracy**: The accuracy on the hidden testing set, providing an unbiased evaluation of the classifier's performance on unseen data.

## Discussion of SVM's accuracy with regard to feature selection

Feature selection plays a crucial role in the performance of the SVM classifier. The selected features should be highly discriminative to enable the classifier to distinguish effectively between LGG and HGG.

(is using repeatability as the sole criteria for feature selection good?)

Using repeatability as the sole criterion for feature selection may not be sufficient. While repeatability ensures that features are consistently measured, it does not necessarily imply that they are the most discriminative for classification. Other criteria, such as relevance to the classification task, statistical significance, and robustness to noise, should also be considered to ensure the selection of the most effective features.

## Challenges during the classification process

Several challenges were encountered during the classification process:

- **Approaching the problem**: The problem seemed comlicated and intimidating at the first glance, but we have found a very useful toolbox in MATLAB for training SVM models which abstract away the coding problem for us to concentrate on the actual design of the model training.
- **Class Imbalance**: The dataset had a significant class imbalance between LGG and HGG patients, which can lead to biased classification results. This was addressed through various resampling techniques.
- **Feature Selection**: Identifying the most relevant features for classification was challenging due to the high dimensionality of the feature space and the need to avoid overfitting.
- **Model Validation**: Ensuring the SVM classifier generalizes well to unseen data required careful validation and tuning of hyperparameters.
- **Computational Complexity**: Training the SVM classifier, especially with large feature sets and cross-validation, was computationally intensive.
