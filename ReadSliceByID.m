% @brief Read slice by volume ID nad slice ID.
% @param volume_path    Path to the volume containing its all slice(s).
% @param volume_ID      ID of volume.
% @param slice_ID       ID of slice inside the volume directory.
% @return slice         One slice indicated by slice ID and volume ID.
%                       Containing four channels.
% @return masks         Three masks from the slice, indicating the tumor
%                       messages, uncombined.
function [slice, masks] = ReadSliceByID(volume_path, volume_ID, slice_ID)
    subdir_name = strcat("volume_", num2str(volume_ID));
    fn = strcat(subdir_name, "_slice_", num2str(slice_ID), ".h5");
    
    fullFileName = fullfile(volume_path, subdir_name, fn);
    fullFileName = strrep(fullFileName, '\', '/');
    
    slice = h5read(fullFileName, '/image');
    masks = h5read(fullFileName, '/mask');
end
