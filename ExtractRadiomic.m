function radiomic_features_avg = ExtractRadiomic(data_directory, volume_ID, transformed)

% data_directory = 'data';
% volume_ID = 1;

addpath('NIfTI_20140122');

% Read MRI slices and tumor masks from .h5 files

mri_slices = zeros(4, 155, 240, 240); % Assuming there are 155 slices
tumor_masks = uint8(zeros(155, 240, 240)); % Assuming there are tumor masks for each slice
% 
for i = 1:155
    % Read the data from H5 files
    [mri_slice, tumor_mask] = ReadSliceByID(data_directory, volume_ID, i-1); % Implement ReadSliceByID() function
    for j=1:3
        mri_slices(j, i, :, :) = mri_slice(j, :, :);
        tumor_masks(i, :, :) = tumor_masks(i, :, :) + tumor_mask(j, :, :);
    end
    mri_slices(4, i, :, :) = mri_slice(4, :, :);
end

if transformed
    % Perform an affine transform, rotated the brain by 5 degree
    tform_I = affinetform3d(generateAffineInfo([0 1 0.2], 5*2*pi/360, [0 0 0]));
else
    % Perform no transform, hence an [I] is input
    tform_I = affinetform3d(eye(4));
end

% sizes(2:end) denotes the dimension for the MRI pictures [240 240] in this
% project.
sizes = size(mri_slices);
medobjprop_mri = medicalref3d(sizes(2:end), tform_I);
medobjprop_masks = medicalref3d(sizes(2:end), tform_I);
% Set the coordinate system property of the voxel
medobjprop_masks.PatientCoordinateSystem = "LPS+";
medobjprop_mri.PatientCoordinateSystem = "LPS+";

% Create a medical object for tumor mask
medobj_mask = medicalVolume(tumor_masks, medobjprop_masks);

shapefeatures = table();        % Create table for shape features
intensityfeatures = table();    % Create table for intensity features
texturefeature = table();       % Create table for texture features

% Repeat for 4 channels
for i=1:4
    medobj_mri = medicalVolume(squeeze(mri_slices(i, :, :, :)), medobjprop_mri);
    % Create medical object for each channel
    R = radiomics(medobj_mri, medobj_mask);
    shapefeatures(i, :) = shapeFeatures(R);             % Extract and append shape features
    intensityfeatures(i, :) = intensityFeatures(R);     % Extract and append intensity features
    texturefeature(i, :) = textureFeatures(R);          % Extract and append texture features
end

% Get rid of non-numerical elements in the table
shapefeatures = Numericalize(shapefeatures);
intensityfeatures = Numericalize(intensityfeatures);
texturefeature = Numericalize(texturefeature);
% Append all three features to radiomic feature
radomic_features = [shapefeatures intensityfeatures texturefeature];

% Average the radiomic features along channels
radiomic_features_avg = sum(radomic_features, 1);
radiomic_features_avg = radiomic_features_avg ./ 4;

end

% Get rid of all the non-numerical elements in the table
function num_table = Numericalize(src)
    varname_list = src.Properties.VariableNames;
    num_table = src;
    for i=1:length(varname_list)
        if ~isnumeric(src(1, i))
            try
                num_table = removevars(num_table, varname_list(1));
            catch err
                disp(strcat(err.message, 'Skipped'));
            end
        end
    end
end