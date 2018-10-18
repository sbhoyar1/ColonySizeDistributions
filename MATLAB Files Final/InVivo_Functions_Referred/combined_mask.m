function [I_out1, I_out2] ...
    = combined_mask(I1_watershed, I2_watershed, ...
                    I1,           I2,           ...
                    I_DAPI,       dilation_metric   )
% This function creates a mask - it blocks out large mets already segmented
% (by watershed, say) by setting the values of those regions as zero.
% I_out1, I_out2 are the masked images in two channels. I1, I2 are the
% original images, I1_watershed is the segmented image. 
% Dilation metric is the value beyond the boundary of the
% large met that is blacked out.

    %% Individual channel masks
I_out1 = ones(size(I1_watershed));                % Make a white image
I_out1(I1_watershed == 0) = 0;                    % Find Mets

I_out2 = ones(size(I2_watershed));
I_out2(I2_watershed == 0) = 0;

    %% Combined Mask
I_out = (I_out1 | I_out2);
% Combine the mets and invert image - mets become zeroes.
I_out = imcomplement(imdilate(I_out, strel('disk',dilation_metric)));

I_out1 = I1;
I_out1(I_out == 0) = 0;
I_out1(I_DAPI == 0) = 0;

I_out2 = I2;
I_out2(I_out == 0) = 0;
I_out2(I_DAPI == 0) = 0;

%figure, imshow(I_out1), title([inputname(3) ' - small mets'])
%figure, imshow(I_out2), title([inputname(4) ' - small mets']) 

end
