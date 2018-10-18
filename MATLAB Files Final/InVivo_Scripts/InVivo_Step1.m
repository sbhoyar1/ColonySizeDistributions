%% Documentation.
% This script segments both large and small mets and collates the areas in
% a spreadsheet.
% Keep the script in the same folder as your image folders. Each image
% folder must contain the .tif images with the lung sections

%% Initialize.

close all
clear
warning('off', 'images:initSize:adjustingMag'); % Switch off the warning:
% 'Image is too big to be displayed, hence being shown at X% of original'


list = dir; % 'list' is the list of image folders
list = list(~ismember({list.name},{'.' '..'}));
list = list([list.isdir]); 

l=length(list);

Overall_RFP_Areas = [];
Overall_GFP_Areas = [];

%% LOOP START.

for z = 1:l     % Loops over each image folder
    close all
    cd(list(z).name);                           % Enter image folder
    
     % Get metadata, based on a specific naming convention of the images
    [day, mouse] = get_metadata(z, list);      
        
        %Read images: Default cytation5 naming convention means the names con-
        %tain the channel name. This is used to get the images. Each folder can
        %only contain one image of each channel.
    gfp = dir('*GFP*'); %Picks up any file with 'GFP' in its name
    rfp = dir('*RFP*');
    dapi = dir('*DAPI*');

        % Store images
    GFP = imread(gfp.name);
    RFP = imread(rfp.name);
    DAPI = imread(dapi.name);

    %% PART 1:  GFP Mets
   
    [GFP_adj, GFP_bin] = lung_colony_preprocess_set2(GFP);
    GFP_watershed = lung_watershed_extendmax(GFP_adj, GFP_bin); clear GFP_adj;
    GFP_met_data = data_from_watershed(GFP_watershed);
    
    clear GFP_bin;
    
    % Store Areas  
    GFP_met_areas = [GFP_met_data.Area];
%     figure
%     histogram(GFP_met_areas)
%     title('Histogram of GFP Met Area');

    disp('Part 1 COMPLETED')
    

    %% PART 2:  RFP Mets
   
    [RFP_adj, RFP_bin] = lung_colony_preprocess_set2(RFP);
    RFP_watershed = lung_watershed_extendmax(RFP_adj, RFP_bin); clear RFP_adj;
    RFP_met_data = data_from_watershed(RFP_watershed);
    
    clear RFP_bin
    
    % Store Areas  
    RFP_met_areas = [RFP_met_data.Area];

    disp('Part 2 COMPLETED')
    
    %% PART 3:  Whole Lung Area
    
    [DAPI_lung, DAPI_BW, lung_area, lung_morphology_area] ...
        = segment_whole_lung(DAPI);
    

    disp('Part 3 COMPLETED') 
    
    %% PART 4: Segment small mets
    
    % Mask mets already segmented            
    [GFP_smallmets, RFP_smallmets] = ...
                        combined_mask(                                  ...
                                        GFP_watershed, RFP_watershed,   ...
                                        GFP,           RFP,             ...
                                        DAPI_lung,     40               ...
                                     );
        
    %figure, imshow(GFP_smallmets), title('GFP Small mets')
    %figure, imshow(RFP_smallmets), title('RFP Small mets')
    
    % Small mets segmentation
    [GFP_bin_small, GFP_smallmet_data] = smallmet_data(GFP_smallmets, 4, 0.9);
    [RFP_bin_small, RFP_smallmet_data] = smallmet_data(RFP_smallmets, 4, 0.9);
    
    
    %% PART 5 - Remove all overlaps and update smallmet_data
    ratio = 0.75;
    [GFP_smallmet_data_updated, RFP_smallmet_data_updated] =            ...
                                                                        ...
                  remove_overlaps(                                      ...
                                 GFP_smallmet_data, RFP_smallmet_data,  ...
                                 GFP,               RFP,                ...
                                 GFP_bin_small,     RFP_bin_small,      ...
                                 DAPI,              ratio               ...
                                 );
            
    clear GFP RFP DAPI DAPI_lung DAPI_BW GFP_bin_small RFP_bin_small
    
    %% PART 6 - Combine met data and add metadata
    RFP_allmet_data = [RFP_met_data; RFP_smallmet_data_updated];
    GFP_allmet_data = [GFP_met_data; GFP_smallmet_data_updated];
    
    [RFP_allmet_data(:).Day] = deal(day);
    [RFP_allmet_data(:).MouseNo] = deal(mouse);
    
    [GFP_allmet_data(:).Day] = deal(day);
    [GFP_allmet_data(:).MouseNo] = deal(mouse);
    
    % Metadata
    Overall_RFP_Areas = [Overall_RFP_Areas; [RFP_allmet_data.Day;       ...
                                             RFP_allmet_data.MouseNo;   ...
                                             RFP_allmet_data.Area]'];
                                         
    Overall_GFP_Areas = [Overall_GFP_Areas; [GFP_allmet_data.Day;       ...
                                             GFP_allmet_data.MouseNo;   ...
                                             GFP_allmet_data.Area]'];
                                         
    
    %% Save Images
    %[~, R_cart, G_cart] = lung_cartoon(RFP_bin, GFP_bin);
    %clear RG_cart
    %imwrite(R_cart, 'Red.tif', 'tiff')
    %imwrite(G_cart, 'Green.tif', 'tiff')
    

    
    cd
    cd ..
end

xlswrite('Met_Areas.xlsx', Overall_RFP_Areas,'RFPdata');
xlswrite('Met_Areas.xlsx', Overall_GFP_Areas,'GFPdata');


