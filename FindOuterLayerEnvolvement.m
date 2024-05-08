function Envol = FindOuterLayerEnvolvement(volume_path, volume_ID, slice_num)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    totalBound = 0;
    totalEnvol = 0;
    for i=1:slice_num
        [boundaryBrain, overlapMask] = FindEnvolvementSingleSlice(volume_path, volume_ID, i-1); % starts with slice_0
        
        % Total number of pixels in the outer layer
        totalBound = totalBound + sum(boundaryBrain(:)); 
        % Number of overlapping pixels
        totalEnvol = totalEnvol + sum(overlapMask(:)); 
    end
        % Calculate the percentage of the overlapping region compared to the total outer layer area
        Envol = (totalEnvol / totalBound) * 100;
        
        disp(['Percentage of outer layer overlapped by tumor: ', num2str(Envol), '%']);
end

function [boundaryBrain, overlapMask] = FindEnvolvementSingleSlice(volume_path, volume_ID, slice_ID)
    [images, tumorMasks] = ReadSliceByID(volume_path, volume_ID, slice_ID);
    
    % process im
    im = squeeze(images(1, :, :));
    threshold = 0.5; 
    im = im > threshold; % Create a binary mask using thresholding
    
    % smooth and close disconnected sections
    se = strel('disk', 10); % kernel to close brain im
    % close the brain to connect all parts/islands
    closedBrain = imerode(imdilate(im, se), se);
    
    thickness = strel('disk', 5); % kernel to find boundary
    boundaryBrain = closedBrain - imerode(closedBrain, thickness);

    % process masks
    % sizes = size(tumorMasks);
    % if sizes(1) == 0
    %     disp("No mask specified");
    %     overlapMask = 0;
    % else
        masks = squeeze(logical(sum(tumorMasks, 1)));
                
        % Calculate the intersection between the dilated tumor mask and the original tumor mask
        overlapMask = boundaryBrain & masks;
    % end
end