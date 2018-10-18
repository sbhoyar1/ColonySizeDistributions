function [GFP_smallmet_data_updated, RFP_smallmet_data_updated] =       ... 
                  remove_overlaps(                                      ...
                                 GFP_smallmet_data, RFP_smallmet_data,  ...
                                 GFP,               RFP,                ...
                                 GFP_binarized,     RFP_binarized,      ...
                                 DAPI,              ratio               ...
                                 )
% This function removes all pixels that are bright in both GFP and RFP
% channel. This removes false positives from the smallmet data. 

        
    for i = 1:size(GFP_smallmet_data, 1) % For each met...
        for j = 1:size(GFP_smallmet_data(i).PixelList, 1) % For each pixel in met...
            %if the ratio of RFP/GFP or DAPI/GFP is more than 70% in the pixel given by the coordinates contained in:
            % GFP_smallmet_data(i).Pixellist(j, :), then REJECT that pixel - make it
            % zero
            GFP_pix_value = im2double(GFP(GFP_smallmet_data(i).PixelList(j, 2), GFP_smallmet_data(i).PixelList(j, 1)));
            RFP_pix_value = im2double(RFP(GFP_smallmet_data(i).PixelList(j, 2), GFP_smallmet_data(i).PixelList(j, 1)));
            DAPI_pix_value = im2double(DAPI(GFP_smallmet_data(i).PixelList(j, 2), GFP_smallmet_data(i).PixelList(j, 1)));
            
            
            if RFP_pix_value/GFP_pix_value > ratio
                GFP_binarized(GFP_smallmet_data(i).PixelList(j, 2), GFP_smallmet_data(i).PixelList(j, 1)) = 0;
            elseif DAPI_pix_value/GFP_pix_value > 0.6
                %GFP_binarized(GFP_smallmet_data(i).PixelList(j, 2), GFP_smallmet_data(i).PixelList(j, 1)) = 0;
            end    
        end
    end

    for i = 1:size(RFP_smallmet_data, 1)
        for j = 1:size(RFP_smallmet_data(i).PixelList, 1)
            % Repeat the above for each pixel in the RFP mets
            GFP_pix_value = im2double(GFP(RFP_smallmet_data(i).PixelList(j, 2), RFP_smallmet_data(i).PixelList(j, 1)));
            RFP_pix_value = im2double(RFP(RFP_smallmet_data(i).PixelList(j, 2), RFP_smallmet_data(i).PixelList(j, 1)));
            DAPI_pix_value = im2double(DAPI(RFP_smallmet_data(i).PixelList(j, 2), RFP_smallmet_data(i).PixelList(j, 1)));

            if GFP_pix_value/RFP_pix_value > ratio
                RFP_binarized(RFP_smallmet_data(i).PixelList(j, 2), RFP_smallmet_data(i).PixelList(j, 1)) = 0;
            elseif DAPI_pix_value/RFP_pix_value > 0.6
                %RFP_binarized(RFP_smallmet_data(i).PixelList(j, 2), RFP_smallmet_data(i).PixelList(j, 1)) = 0;
            end
        end
    end
    
    GFP_cc_new = bwconncomp(GFP_binarized);
    GFP_smallmet_data_updated = regionprops(GFP_cc_new, 'Area', 'PixelIdxList', 'PixelList', 'BoundingBox');
    RFP_cc_new = bwconncomp(RFP_binarized);
    RFP_smallmet_data_updated = regionprops(RFP_cc_new, 'Area', 'PixelIdxList', 'PixelList', 'BoundingBox');

%figure, imshow(RFP_binarized), title([inputname(4) 'small mets binarized'])
%figure, imshow(GFP_binarized), title([inputname(3) 'small mets binarized'])
    
end
