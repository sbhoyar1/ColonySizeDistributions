function [I_adj, I_bin] = lung_colony_preprocess_set2(I)
% This function is to preprocess the 100%-stitched images. 
% It is used in the script that gets cropped images of tumors to get 
% cell-size estimates.

    %% Blur images using a gaussian filter
    
I_adj = imgaussfilt(I,16);
figure, imshow(I), title([inputname(1) ' - Original']);
% figure, imshow(I_out), title('Blurred');

    %% Improve contrast, binarize
    
I_adj = imadjust(I_adj, stretchlim(I, 0.001));
% figure, imshow(GFP_adjust), title('Contrast adjust');

I_bin = imbinarize(I_adj);
% figure, imshow(GFP_binarized), title('Otsu thresholding');


end