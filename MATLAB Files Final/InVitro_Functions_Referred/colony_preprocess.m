function [I_out] = colony_preprocess(I, min_area)
% All preprocessing steps required for the colony segmentation
%figure, imshow(I), title('Original');

%   Log Transform  
I_out = imadjust(I, [0; 0.60], [0; 1], 3); 
%figure, imshow(I_out), title('Transformed')

%   Gaussian Blur
I_out = imgaussfilt(I_out,8);
%figure, imshow(I_out), title('Blurred');

%   Binarize
I_out = imbinarize(I_out, 0.017);
%figure, imshow(I_out), title('Otsu thresholding');

%   Remove Small Objects
I_out = bwareaopen(I_out, min_area);
end
