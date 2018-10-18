function [I_bin, smallmet_struct] = smallmet_data(I, gamma, binthresh)
% This function provides a structure with the data from mets not segmented
% in the watershed-extendedmax type of segmentation.
% 'I' - Masked image
% 'gamma' - Gamma value for the adjustment step. '2' - Tumor removal exp.
% 'binthresh' - binarization threshold for the binarization step. '0.85'


    %% Process masked image
%figure, imshow(GFP), title('GFP');

I_adj = imadjust(I, [0; 0.85], [0; 1], gamma); % Log transform
%figure, imshow(I_adj), title([inputname(1) ' - log transformed, gamma = ' num2str(gamma)]);

I_bin = imbinarize(I_adj, binthresh);
%figure, imshow(GFP_binarized), title('GFP - binarized');

%I_bin = imdilate(I_bin, strel('disk', 5));
%figure, imshow(I_bin), title([inputname(1) ' - dilated']);

    %% Data Collection
I_cc = bwconncomp(I_bin);     % Create object list
smallmet_struct = regionprops(I_cc, 'Area', 'PixelIdxList', 'PixelList', 'BoundingBox');

end
