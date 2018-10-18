function [I_out] = watershed_disttr(I)
% This function applies a distance transform and watershed segmentation
% algorithm to the pre-processed colonies.
% Output: I_out = image with watersheds identified

I_perim = bwperim(I);

    %% Distance transform
dist_tr = bwdist(~I);
%figure, imshow(dist_tr, []), title('Distance transform')
dist_tr = - dist_tr;
dist_tr(~I) = Inf;
dist_tr = imhmin(dist_tr,5); %50 is the height threshold for suppressing shallow minima
%figure, imshow(dist_tr, []), title('dist tr final')

    %% Watershed
I_out = watershed(dist_tr);
I_out(~I) = 0;
%figure, imshow(I_out), title('Watershed')

    %% Display segmented colonies
rgb = label2rgb(I_out,'jet',[.5 .5 .5], 'shuffle');
figure, imshow(rgb), title('Segmentation by Watershed')
end
