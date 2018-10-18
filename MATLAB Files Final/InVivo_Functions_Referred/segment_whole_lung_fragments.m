function [  I_gross_lung,       ... 
            I_morphological,    ...
            lung_area,          ...
            lung_morphology_area    ] = segment_whole_lung_fragments(I)
% This function segments the full lung region, and removes mets that lie
% outside this region.

SE = strel('disk', 2);
SE1 = strel('disk', 20);

    %% Segment the lung region
I_adj = imadjust(I);
%figure, imshow(I_adj), title('DAPI-adjusted');

I_morphological = imbinarize(I_adj, .2);
%figure, imshow(DAPI_BW), title('DAPI-BW');

I_BW2 = imerode(I_morphological, SE);
%figure, imshow(I_eroded), title('eroded')

I_BW2 = imdilate(I_BW2, SE1);
%figure, imshow(I_e_dilated), title('dilated')

I_BW2 = imfill(I_BW2, 'holes');
%figure, imshow(I_BW2), title('filled');

I_gross_lung = imerode(I_BW2, SE1);
%figure, imshow(I_lung), title('lung outline')

lung_cc = bwconncomp(I_gross_lung);    % Lung conncomp
lung_data = regionprops(lung_cc, 'Area', 'PixelIdxList', 'PixelList');

    %% Identify lung region (biggest area), get rid of false bright spots
[lung_area, index] = max([lung_data.Area]);     % Gross Lung area

lung_outline = bwperim(I_gross_lung);
lung_region = zeros(size(I_gross_lung, 1), size(I_gross_lung, 2));
lung_region = I_gross_lung;

%I_gross_lung(lung_region == 0) = 0;   % Remove False bright spots (Gross area)
I_morphological(lung_region == 0) = 0;     % Remove False bright spots (Morphological)

lung_morphology_area = sum(I_morphological(:));            % Morphological lung area

end
