function [red_frac] = colony_classify(cc_data, RedMask, GreenMask, i)
% [red_frac] = redgreen_classify(cc_data, RedMask, GreenMask, i)
% This function assigns a metric (red_frac) to each colony, which can be used
% as the basis of classifying a colony as red/ green/ mixed.

%   Colony mask
I = false(size(RedMask));
I(cc_data(i).PixelIdxList) = true;
%figure, imshow(I), title('i-th colony location')

%   In both masks, make all areas outside of the colony = 0
RedMask(imcomplement(I)) = false;
GreenMask(imcomplement(I)) = false;

red_frac = sum(RedMask(:))/ (sum(RedMask(:)) + sum(GreenMask(:)));
end
