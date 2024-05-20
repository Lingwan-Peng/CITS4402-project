% @brief: Find the maximum tumor diameter for a volume
% @param volume_path: The path of all the subfolders.
% @param volume_ID: ID of the volume.
% @param slice_num: Number of the slice in the subfolder
% @return: The maximum diameter of the tumor in the indicated volume
function Dmax = FindMaxDiameter(volume_path, volume_ID, slice_num)
    Darray = zeros(1, slice_num);
    for i=1:slice_num
        Darray(i) = FindDiameterSingleSlice(volume_path, volume_ID, i-1);
    end
    Dmax = max(Darray);
end


function D = FindDiameterSingleSlice(volume_path, volume_ID, slice_ID)
    [~, masks] = ReadSliceByID(volume_path, volume_ID, slice_ID);
    
    sizes = size(masks);
    % Requires mask
    if sizes(1) == 0
        disp("No mask specified");
        D = 0;
    else
        % Combine the mask (join)
        mask_combined = squeeze(logical(sum(masks, 1)));
        % Find the bounding rectangles for all the areas indicated by the
        % combined mask
        stats = regionprops('table', mask_combined, 'Area', 'BoundingBox');
        boundingBoxes = stats.BoundingBox;
        
        if ~isempty(boundingBoxes)          % Check if any rectangle founds
            [~, idx] = max(stats.Area);     % Find the largest bounding rectangle
            boundingBox = boundingBoxes(idx, :);
            WL = boundingBox(3:end);
            D = max(WL);                    % The maximum diameter is the length of the largest rectangle
        else
            D = 0;                          % If not found, the diameter is 0
        end
    end
end