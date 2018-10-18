function [list_r, list_g] = choose_images_rg(well)
% This function gets the filenames of all images of the desired well,
% sorted by GFP/RFP.

%% ReadMe:
% This function is applicable to LiveCell (Red/Green channels) experiments.

%% Initialize
well = strcat(well, '_*');

list_of_GFP_images = {}; j = 1;
list_of_RFP_images = {}; k = 1;

list_of_images_from_well = dir(well);

%% Check if each image is GFP or RFP
for i = 1:length(list_of_images_from_well)
    
    GFP_check = contains(list_of_images_from_well(i).name, 'GFP');
    RFP_check = contains(list_of_images_from_well(i).name, 'RFP');
    
    if GFP_check == 1
        list_of_GFP_images{j} = list_of_images_from_well(i).name;
        j = j + 1;  
    elseif RFP_check == 1
        list_of_RFP_images{k} = list_of_images_from_well(i).name;
        k = k + 1;
    else
    end
end

        
list_r = list_of_RFP_images';
list_g = list_of_GFP_images';

