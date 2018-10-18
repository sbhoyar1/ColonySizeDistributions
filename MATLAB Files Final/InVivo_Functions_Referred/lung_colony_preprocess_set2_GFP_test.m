function [I_adj, I_bin] = lung_colony_preprocess_set2_GFP_test(I)
% This function is to preprocess the 100%-stitched images. 
% It is used in the script that gets cropped images of tumors to get 
% cell-size estimates.

    %% Blur images using a gaussian filter
    
I_adj = imgaussfilt(I,8);
figure, imshow(I), title([inputname(1) ' - Original']);
% figure, imshow(I_out), title('Blurred');

    %% Improve contrast, binarize
    
I_adj = imadjust(I_adj, stretchlim(I, 0.001));
 %figure, imshow(I_adj), title('GFP Contrast adjust');

I_bin = imbinarize(I_adj, 0.6);
 %figure, imshow(I_bin), title('GFP  thresholding');


end