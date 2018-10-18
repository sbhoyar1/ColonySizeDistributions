function I_watershed = lung_watershed_extendmax(I_adj, I_bin)
% This function segments the lung mets using the watershed+extendedmaxima.
% 'I_bin' is the binarized image obtained in the previus step.
% 'I_adj' is the adjusted image obtained in the previous step.

    %% Discover approximate cell maxima and process them
I_perim = bwperim(I_bin);
I_extmax = imextendedmax(I_adj,  3000);
I_extmax = imclose(I_extmax, strel('disk',5));
I_extmax = imfill(I_extmax, 'holes');
I_extmax = bwareaopen(I_extmax, 5);

Max_overlay = imoverlay(I_adj, I_perim | I_extmax, [1 .3 .3]);
%figure, imshow(Max_overlay), title('Maxima');


    %% Impose Minima at bright areas 
    % This creates 'watersheds' which are segmented in the next section
    
I_comp = imcomplement(I_adj);
I_imposemin = imimposemin(I_comp, ~I_bin | I_extmax);

%figure, imshow(I_imposemin), title('Inverted Maxima');


    %% Apply watershed
I_watershed = I_imposemin;              % Get inverted minima
I_watershed(~I_bin) = Inf;              % Make bground Inf (white)
I_watershed = watershed(I_watershed);   % Segment
I_watershed(~I_bin) = 0;                % Make bground regions 0
end
