%% Documentation
% RUGT
% This script analyzes images with the following parameters:

% 1. Live cell (RFP, GFP channels only)
% 2. MCF7 Cell Line
% 3. Multiple time points
% 4. Optimized for 06MAR Experiment, with distance transform

% The script obtains colony data from the images

%% Preparation

warning('OFF', 'images:initSize:adjustingMag'); 
% Turns off the image-size warning ('Image is too big to fit on screen;
% displaying at XX%')

clear
close all

Day = [];
Data_Red = {};
Data_Green = {};



%% Inputs

% Loop control
i1 = 1; i2 = 3;
% The above variables specify number of time points. The list can be seen
% any time by typing 'list_r' or 'list_g' into the console.

all_wells = {'A1', 'A2', 'A3', 'B1', 'B2', 'B3'};

for well_counter = 1:length(all_wells)
    well = all_wells{well_counter}
    
report_red = [];
report_green = [];

% Get lists of RFP and GFP images
[list_r, list_g] = choose_images_rg(well);

%% Loop over images and binarize
    

for i = i1:i2 %length(list_g)
    disp(i)
    
    % Read images
    
    I_green_name = list_g{i};
    I_green = imread(I_green_name);
    
    I_red_name = list_r{i};
    I_red = imread(I_red_name);
    
    
    % Get the 'day' labels.
    k = strfind(I_green_name, '_D_');
    Day(i) = str2num(strcat(I_green_name(k+3), I_green_name(k+4))); 
    Data_Green(1, i) = {Day(i)};
    
    m = strfind(I_red_name, '_D_');
    Day(i) = str2num(strcat(I_red_name(m+3), I_red_name(m+4)));
    Data_Red(1, i) = {Day(i)};
    
    
    if Day(i) > 4
        
        
            % Preprocess and binarize
            % Change the threshold within the function if required, based
            % on some initial manual comparisons.
        GFP_bin = MCF7_colony_preprocess_GFP(I_green);
        RFP_bin = MCF7_colony_preprocess_RFP(I_red);
        
    else
            % Preprocess and binarize small colonies (no blurring)
        GFP_bin = MCF7_colony_preprocess_noblur_GFP(I_green);
        RFP_bin = MCF7_colony_preprocess_noblur_RFP(I_red);
        GFP_bin1 = GFP_bin;
    end       
    
    
    % Remove all double positives from RFP channel. This applies to MFC7
    % cells since in our MCF7 cell line the GFP cells show up in the RFP channel as well.
    RFP_bin(GFP_bin == 1) = 0; 
    
    
        % Save GFP mask as an image
GFP_image_filename = strcat(well, '_GFP_mask_image.tif');
imwrite(GFP_bin, GFP_image_filename);

        % Save RFP mask as an image
RFP_image_filename = strcat(well, '_RFP_mask_image.tif');
imwrite(RFP_bin, RFP_image_filename);
    
    % Get data from colonies
    
    red_colony_data_temp = watershed_disttr_segment(RFP_bin, 0);
    red_colony_data_temp = red_colony_data_temp([red_colony_data_temp.Area]>5,       :);
    [red_colony_data_temp.Day] = deal(Day(i));
    
    green_colony_data_temp = watershed_disttr_segment(GFP_bin, 0);
    green_colony_data_temp = green_colony_data_temp([green_colony_data_temp.Area]>5, :);
    [green_colony_data_temp.Day] = deal(Day(i));
    
    clear GFP_bin GFP_bin1 RFP RFP_bin
    
    
    clear I_red I_green
    
    Data_Red(2, i) = {red_colony_data_temp};
    Data_Green(2, i) = {green_colony_data_temp};
    
    report_red = [report_red;[[red_colony_data_temp.Day]', [red_colony_data_temp.Area]']];
    report_green = [report_green;[[green_colony_data_temp.Day]', [green_colony_data_temp.Area]']];
                 
   close all
end

Data_Red = Data_Red';
Data_Green = Data_Green';

filename_red = strcat(well, '_Red');
filename_green = strcat(well, '_Green');
save(strcat(filename_red, '.mat'), 'Data_Red');
save(strcat(filename_green, '.mat'), 'Data_Green');

%figure, imshow(I_green)
%figure, imshow(I_red)
end


