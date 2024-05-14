% @brief: Find the maximum tumor area for a volume
% @param volume_path: The path of all the subfolders.
% @param volume_ID: ID of the volume.
% @param slice_num: Number of the slice in the subfolder
% @return: The maximum area of the tumor in the indicated volume
function Amax = FindMaxArea(volume_path, volume_ID, slice_num)
    Aarray = zeros(1, slice_num);
    for i=1:slice_num
        Aarray(i) = FindAreaSingleSlice(volume_path, volume_ID, i-1);
    end
    Amax = max(Aarray);
end


function A = FindAreaSingleSlice(volume_path, volume_ID, slice_ID)
    [~, masks] = ReadSliceByID(volume_path, volume_ID, slice_ID);
    
    sizes = size(masks);
    if sizes(1) == 0
        disp("No mask specified");
        A = 0;
    else
    
        mask_combined = squeeze(logical(sum(masks, 1)));
        % Threshold the binary image to separate white pixels
        threshold = 0.5; % Adjust the threshold as needed
        binary_image_thresholded = mask_combined > threshold;
                            
        % Count the number of white pixels
        num_white_pixels = sum(binary_image_thresholded(:));
    
        A = num_white_pixels;
    end
    
end
