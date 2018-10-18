function I_met_data = data_from_watershed(I_watershed)
% This function grabs the data from the output of the 'watershed' function
% in MATLAB. The data is stored as a struct.

    %% Create object list
I_cc = bwconncomp(I_watershed);     % Create object list
I_label_matrix = labelmatrix(I_cc);
whos labeled;
I_label = label2rgb(I_label_matrix, @spring, 'c', 'shuffle');

figure, imshow(I_label), title([inputname(1) ' - segmented']);

    %% Metastatic tumor data
I_met_data = regionprops(I_cc, 'Area', 'PixelIdxList', 'PixelList', 'BoundingBox');