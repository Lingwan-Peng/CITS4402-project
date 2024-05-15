function radiomic_features_avg = ExtractRadiomic(data_directory, volume_ID)
% 
% data_directory = 'data';
% volume_ID = 1;

addpath('NIfTI_20140122');

% Read MRI slices and tumor masks from .h5 files

mri_slices = zeros(4, 155, 240, 240); % Assuming there are 155 slices
tumor_masks = uint8(zeros(155, 240, 240)); % Assuming there are tumor masks for each slice
% 
for i = 1:155 % Update the loop range as needed
    [mri_slice, tumor_mask] = ReadSliceByID(data_directory, volume_ID, i-1); % Implement ReadSliceByID() function
    for j=1:3
        mri_slices(j, i, :, :) = mri_slice(j, :, :);
        tumor_masks(i, :, :) = tumor_masks(i, :, :) + tumor_mask(j, :, :);
    end
    mri_slices(4, i, :, :) = mri_slice(4, :, :);
end

sizes = size(mri_slices);
medobjprop_mri = medicalref3d(sizes(2:end));
medobjprop_masks = medicalref3d(sizes(2:end));

medobjprop_masks.PatientCoordinateSystem = "LPS+";
medobjprop_mri.PatientCoordinateSystem = "LPS+";

medobj_mask = medicalVolume(tumor_masks, medobjprop_masks);

shapefeatures = table();

for i=1:4
    medobj_mri = medicalVolume(squeeze(mri_slices(i, :, :, :)), medobjprop_mri);
    
    R = radiomics(medobj_mri, medobj_mask);
    shapefeatures(i, :) = shapeFeatures(R);
end

radiomic_features_avg = sum(shapefeatures(:, 2:end), 1);
radiomic_features_avg = radiomic_features_avg ./ 4;

end