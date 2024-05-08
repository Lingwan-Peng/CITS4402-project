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
    if sizes(1) == 0
        disp("No mask specified");
        D = 0;
    else
        mask_combined = squeeze(logical(sum(masks, 1)));

        stats = regionprops('table', mask_combined, 'Area', 'BoundingBox');
        boundingBoxes = stats.BoundingBox;
        if ~isempty(boundingBoxes)
            [~, idx] = max(stats.Area);
            boundingBox = boundingBoxes(idx, :);
            WL = boundingBox(3:end);
            D = max(WL);
        else
            D = 0;
        end
    end
end