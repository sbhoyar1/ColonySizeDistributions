function [AreaI, CellCountI, SumInt, SumIntBin, KI67Frac] = colony_metrics_ki67(cc_data, I1, ki67, i, CountCells, ShowImages, well)
% [AreaI, CellCountI, SumInt, SumIntBin] = colony_metrics(cc_data, Image, i, CountCells, ShowImages)
%This function collects i-th colony metrics: Number of cells, SumInt and
% binarized SumInt (SumIntBin). It also shows the i'th colony. Obtaining
% number of cells in each colony takes time, so you can choose to switch it
% 'off' by setting 'CountCells' to '0'. 

%%   Colony mask
I_out = false(size(I1));
I_out(cc_data(i).PixelIdxList) = true;
if ShowImages == 1
    figure, imshow(I_out), title('i-th colony location')
elseif ShowImages == 0
else
    disp('Error - ShowImages should be 1 or 0 only')
end
    
%   Area
AreaI = cc_data(i).Area;


%%   Colony image
% Darken all regions except the colony, in the original image.
I1(imcomplement(I_out)) = false;
% Crop based on bounding box
I1 = imcrop(I1, cc_data(i).BoundingBox);
I1 = imtophat(I1, strel('disk', 5));

if ShowImages == 1
    figure, imshow(I1), title('i-th colony location')
elseif ShowImages == 0
else
    disp('Error - ShowImages should be 1 or 0 only')
end
I_cellcount = I1;

%%   Metrics to quantify number of cells
% Sum of intensities
SumInt = sum(I1(:));

% Binarized sum of intensities
I1 = imbinarize(I1, 0.2);
if ShowImages == 1
    figure, imshow(I1), title('i-th colony location binarized')
elseif ShowImages == 0
else
    disp('Error - ShowImages should be 1 or 0 only')
end
SumIntBin = sum(I1(:));
% SumIntBin (vs SumInt): Advantage - eliminates contribution from 
% background. Disadvantage - introduces binarization step.
clear I1 I_out

% Number of cells by watershed
if CountCells == 1
    CellCountI = watershed_cell_disttr(imbinarize(I_cellcount));
    CellCount_data = regionprops(CellCountI, 'Area', 'PixelIdxList');    
    CellCountI = length(CellCount_data);
elseif CountCells == 0
    CellCountI = nan;
else
    disp('Error - CountCells should be 1 or 0 only')    
end

if ki67 == 0
    KI67Frac = 0;
else
    
%% KI67 mask
%figure, imshow(ki67);
KI67_binarized = imbinarize(ki67, 0.3);


    % Save KI67 mask as an image
%figure, imshow(KI67_binarized);
KI67_image_filename = strcat(well, '_KI67_mask_image.tif');
imwrite(KI67_binarized, KI67_image_filename);

% Crop the ki67 mask with the same boundaries as the colony image crop
KI67_binarized = imcrop(KI67_binarized, cc_data(i).BoundingBox);
%KI67_crop = imcrop(ki67, cc_data(i).BoundingBox);
%figure, imshow(KI67_crop)
%figure, imshow(KI67_binarized)

if CountCells == 1

    for i = 1:CellCountI
        nucleus_in_colony = CellCount_data(i).PixelIdxList;
        ki67_nucleus = KI67_binarized(nucleus_in_colony);
        ki67_nucleus_frac(i) = sum(ki67_nucleus)/length(ki67_nucleus);
        %disp(ki67_nucleus_frac)
        ki67_nucleus_frac = ki67_nucleus_frac';
    end
    %histogram(ki67_nucleus_frac, 50)
    KI67Frac = sum(ki67_nucleus_frac>0.15)/length(ki67_nucleus_frac);

elseif CountCells == 0
    KI67Frac = nan;
end

end

end
