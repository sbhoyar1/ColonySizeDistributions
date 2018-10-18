function [I_out] = MCF7_colony_preprocess_noblur_GFP(I)


%figure, imshow(I), title('Original');

I_out = imtophat(I, strel('disk', 100));
%figure, imshow(I_out), title('TopHat filter');

%I_out = imgaussfilt(I_out, 16);
% I_out = imadjust(I_out, stretchlim(I_out, 0.0001)); 

I_out = imadjust(I_out, [0, 0.5]);
%figure, imshow(I_out), title('GFP - Adjust');


I_out = imbinarize(I_out, 0.15);
%figure, imshow(I_out), title('GFP - Binarized');