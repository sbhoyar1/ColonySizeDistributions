function colony_data = watershed_disttr_segment(I_bin, switch1)
% This function segments colonies using the distance transform


%% Watershed by Distance Transform
I = I_bin;

I_perim = bwperim(I);

    % Distance transform
dist_tr = bwdist(~I);
%figure, imshow(dist_tr, []), title('Distance transform')
dist_tr = - dist_tr;
dist_tr(~I) = Inf;
dist_tr = imhmin(dist_tr,8); %8 is the height threshold for suppressing shallow minima
%figure, imshow(dist_tr, []), title('dist tr final')

    % Watershed
I_out = watershed(dist_tr);
I_out(~I) = 0;
%figure, imshow(I_out), title('Watershed')

    % Display segmented colonies
rgb = label2rgb(I_out,'jet',[.5 .5 .5], 'shuffle');
figure, imshow(rgb), title('Segmentation by Watershed')

%% Get Colony Data

% Area, PixelIdxList, BoundingBox
colony_data = regionprops(I_out, 'Area', 'PixelIdxList', 'BoundingBox');

% Colony-level images and additional metrics, controlled by switch 1. 

if switch1 == 1
    
    % Create fields in struct
    [colony_data.CellCount] = deal([]);
    [colony_data.PxPerCell] = deal([]);


    for i = 1:length([colony_data.Area])
        disp(i)

        % Image
        Icol = imcrop(I_bin, colony_data(i).BoundingBox);

        % Watershed by distance transform
        Icol = watershed_disttr(Icol); % Deleted h-min transform step from watershed_disttr function

        % Number of cells
        cells_col_cc = bwconncomp(Icol);
        cell_count(i) = length([cells_col_cc.PixelIdxList]);
        colony_data(i).CellCount = cell_count(i);

        % Area (in Pixels) per cell
        px_per_cell(i) = colony_data(i).Area/cell_count(i);
        colony_data(i).PxPerCell = px_per_cell(i);

    end
    
    
else
end


end