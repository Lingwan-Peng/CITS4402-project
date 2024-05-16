data = readtable("rf_sorted.csv");

% extract numeric columns
numericVars = varfun(@isnumeric, data, 'OutputFormat', 'uniform');
numericData = data{:, numericVars};

% Check for infinite values in numeric columns
infIdx = isinf(numericData);
[rowsInf, colsInf] = find(infIdx);

% Replace infinite values with NaNs
numericData(infIdx) = NaN;

% Check for very large values in numeric columns
threshold = 1e6;
largeIdx = abs(numericData) > threshold;
[rowsLarge, colsLarge] = find(largeIdx);
% Cap large values
numericData(largeIdx) = threshold;

% Standardize the data (Z-score normalization)
mu = mean(numericData, 'omitnan');
sigma = std(numericData, 'omitnan');
standardizedData = (numericData - mu) ./ sigma;

% Rebuild the table with cleaned numeric data
data{:, numericVars} = standardizedData;

% 'Grade' is the column with labels 'HGG' and 'LGG'
isHGG = strcmp(data.Grade, 'HGG');
isLGG = strcmp(data.Grade, 'LGG');

% Randomly select 10 HGG and 10 LGG for the test set
rng('default'); % For reproducibility
HGG_test_idx = randsample(find(isHGG), 10);
LGG_test_idx = randsample(find(isLGG), 10);
test_idx = [HGG_test_idx; LGG_test_idx];

% Create test set
test_data = data(test_idx, :);

% Create training set by excluding the test set
train_data = data;
train_data(test_idx, :) = [];

% Re-calculate isHGG and isLGG on the training data
isHGG_train = strcmp(train_data.Grade, 'HGG');
isLGG_train = strcmp(train_data.Grade, 'LGG');

% Separate LGG and HGG in training data
LGG_train_data = train_data(isLGG_train, :);
HGG_train_data = train_data(isHGG_train, :);

% Oversample LGG
oversampled_LGG_train_data = datasample(LGG_train_data, size(HGG_train_data, 1), 'Replace', true);

% Combine HGG and oversampled LGG
balanced_train_data = [HGG_train_data; oversampled_LGG_train_data];

% Save the cleaned data to a new file
% writetable(balanced_train_data, 'balanced_train_data.csv');
% writetable(test_data, 'test_data.csv');