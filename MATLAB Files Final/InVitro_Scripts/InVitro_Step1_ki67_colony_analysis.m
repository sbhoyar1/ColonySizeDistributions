%% Introduction

% This script is for the DAPI-ki67 test performed on 04JAN. There is no RFP
% channel in this system.


%% Initialize

close all
clear
warning('OFF', 'images:initSize:adjustingMag'); 
%This turns off the image-size warning (Image is too big to fit on screen;
%displaying at 13%)
%output_filename = 'ColonyData_ki67.xlsx';

j1 = 1; j2 = 1;
all_wells = {'A1', 'A2', 'A3', 'B1', 'B2', 'B3'};

for well_counter = 1:1%length(all_wells)
    well = all_wells{well_counter}
    
N = [];
    
    % Get lists of RFP, GFP, DAPI and KI67 images
[list_r, list_g, list_d, list_c] = choose_images_rgdc(well);

for j = j1:j2
    disp(j)
    
    GFP = imread(list_g{j});
    RFP = imread(list_r{j});
    DAPI = imread(list_d{j});
    KI67 = imread(list_c{j});
    
    GFP_name = list_g{j};
    k = strfind(list_g{j}, '_D_');
    Day(j) = str2num(strcat(GFP_name(k+3), GFP_name(k+4))); 



%% Preprocessing
KI67 = imtophat(KI67, strel('disk', 50));

    % RFP and GFP masks
GFP_mask = green_mask(GFP, 0.05);
RFP_mask = red_mask(RFP, 0.03);
    
    % Save GFP mask as an image
figure, imshow(GFP_mask);
GFP_image_filename = strcat(well, '_GFP_mask_image.tif');
imwrite(GFP_mask, GFP_image_filename);

    % Save RFP mask as an image
figure, imshow(RFP_mask);
RFP_image_filename = strcat(well, '_RFP_mask_image.tif');
imwrite(RFP_mask, RFP_image_filename);

clear GFP RFP RFP_image_filename GFP_image_filename
close all

%% 1. DAPI IMAGE PROCESSING
    
    % Processing
DAPI_preprocess = colony_preprocess(DAPI, 200);
%figure, imshow(DAPI_preprocess), title('DAPI preprocess');
DAPI_watershed = watershed_disttr(DAPI_preprocess);

DAPI_cc = bwconncomp(DAPI_watershed);
DAPI_data = regionprops(DAPI_cc, 'Area', 'PixelIdxList', 'BoundingBox');

M = zeros(DAPI_cc.NumObjects, 6); % 5 should be 6 if we use redfrac
for i = 1:DAPI_cc.NumObjects % 383:383
    disp(i)
    [Area_i, CellCount_i, SumInt_i, SumIntBin_i, KI67Frac_i] = colony_metrics_ki67(DAPI_data, DAPI, KI67, i, 1, 0, well);
    redfrac_i = colony_classify(DAPI_data, RFP_mask, GFP_mask, i);
    M(i, :) = [Area_i, CellCount_i, SumInt_i, SumIntBin_i, KI67Frac_i, redfrac_i];
end

M(:, 7) = Day(j)



N = [N;M];
end  %Timepoint loop ends


%% Create a spreadsheet with all the metrics
output_filename = strcat(well, '_data.xlsx');
xlswrite(output_filename, N);

end % Well loop ends

