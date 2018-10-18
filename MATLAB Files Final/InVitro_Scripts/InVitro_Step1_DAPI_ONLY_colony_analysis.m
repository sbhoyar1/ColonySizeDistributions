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
all_wells = {'A1' 'A2'};

for well_counter = 1:length(all_wells)
    well = all_wells{well_counter}
    
N = [];
    
    % Get lists of RFP, GFP, DAPI and KI67 images
[list_r, list_g, list_d, list_c] = choose_images_rgdc(well);

for j = j1:j2
    disp(j)

    DAPI = imread(list_d{j});

DAPI_name = list_d{j};
k = strfind(list_d{j}, '_D_');
Day(j) = str2num(strcat(DAPI_name(k+3), DAPI_name(k+4)));




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
    [Area_i, CellCount_i, SumInt_i, SumIntBin_i, KI67Frac_i] = colony_metrics_ki67(DAPI_data, DAPI, 0, i, 1, 0, well);
    M(i, :) = [Area_i, CellCount_i, SumInt_i, SumIntBin_i, KI67Frac_i, 0];
end

M(:, 7) = Day(j);



 N = [N;M];
end  %Timepoint loop ends


%% Create a spreadsheet with all the metrics
output_filename = strcat(well, '_data.xlsx');
xlswrite(output_filename, N);

end % Well loop ends

