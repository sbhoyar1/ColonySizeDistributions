%% Documentation

% Type of histogram: Frequency 
%
% This script processes the data output by the 'L_CombSeg' script into
% histograms, for each individual lungs. 

close all
clear

% Figure size:
x0 = 10;
y0 = 10;
width = 450;
height = 450;

%% Normalization

% Choose from 0, 1 or 2.
% 0: No Normalization
% 1: (R + G) = 1
% 2: R = 1 and G = 1

%dist_red_y = zeros(7, 1001);
%dist_green_y = zeros(7, 1001);

for k = 2:2
    Normalization = k;  
    clear RFP_data GFP_data
    %% User Inputs:

    cell_area_in_pixels = 10;                       % 50% images, 4X mag
    max_tumor_area = 100000;                        % pixels
    %normalize_by_total_metastatic_load = 1;         % 1 = TRUE, 0 = False

    edges = linspace(0,max_tumor_area/cell_area_in_pixels, 100);
    MinCellLimit = 3;

    RFP_lung_areas_combined = [];
    GFP_lung_areas_combined = [];

    %% Obtain and Sort Data from spreadsheet

    % Obtain data from spreadsheet
    RFP_data = xlsread('Met_Areas.xlsx', 'RFPdata');
    GFP_data = xlsread('Met_Areas.xlsx', 'GFPdata');

    RFP_data(:, 3) = RFP_data(:, 3)/cell_area_in_pixels;
    GFP_data(:, 3) = GFP_data(:, 3)/cell_area_in_pixels;

    % Sort data for every mouse
    RFP_data = sort_by_2col(RFP_data, 1, 2, 'Areas', 'Day', 'MouseNo');
    GFP_data = sort_by_2col(GFP_data, 1, 2, 'Areas', 'Day', 'MouseNo');

    % Remove any false mouse numbers (i.e. if they have no segmented areas)

    for i = size(RFP_data, 1):-1:1
        if length(RFP_data{i,1}) == 0
            RFP_data(i, :) = [];
        else
        end
    end
    for i = size(GFP_data, 1):-1:1
        if length(GFP_data{i,1}) == 0
            GFP_data(i, :) = [];
            i = i-1;
        else
        end    
    end

    i1 = 2;
    i2 = size(RFP_data, 1);

    for i = 2:i2
        
        clear RFP_lung_areas GFP_lung_areas red_h green_h
        
        %% Get Individual Lung Data
        disp(i)
        RFP_lung_areas = RFP_data{i, 1};
        RFP_lung_areas(RFP_lung_areas < MinCellLimit ) = []; 
        RFP_MouseNo   = RFP_data{i, 3};
        RFP_Day       = RFP_data{i, 2};

        GFP_lung_areas = GFP_data{i, 1};
        GFP_lung_areas(GFP_lung_areas < MinCellLimit ) = [];
        GFP_MouseNo   = GFP_data{i, 3};
        GFP_Day       = GFP_data{i, 2};

        Total_Met_Count = (length(RFP_lung_areas) + length(GFP_lung_areas));
        
        RFP_Met_Count(i) = length(RFP_lung_areas);
        GFP_Met_Count(i) = length(GFP_lung_areas);
        
        %% Plot Histograms
        % The histograms below plot the colony size distributions for each
        % image (i.e. each lung section) in its own figure. I.e. for 'N'
        % lung section, 'N' figures are generated, each containing two
        % histograms - one for Red mets and one for Green in the same
        % figure. 
        
        % Set Normalization type
        figure
        if Normalization == 0

            %% No Normalization
            % Create histograms

            red_h = histogram(RFP_lung_areas, edges);
            hold on
            green_h = histogram(GFP_lung_areas, edges);

            %% R + G = 1
        elseif Normalization == 1 
            red_counts = histcounts(RFP_lung_areas, edges);
            green_counts = histcounts(GFP_lung_areas, edges);

            red_counts = red_counts/Total_Met_Count;
            green_counts = green_counts/Total_Met_Count;
            
            midpts = edges + (edges(2)/2); midpts(end) = []; %Sort edges to be midpoints

            red_h = bar(midpts, red_counts, 1, 'r');
            hold on
            green_h = bar(midpts, green_counts, 1, 'r');

            %% R = 1 and G = 1
        elseif Normalization == 2

            red_h = histogram(RFP_lung_areas, edges, 'Normalization', 'probability');
            hold on
            green_h = histogram(GFP_lung_areas, edges,  'Normalization', 'probability');
        else
            disp('Incorrect input for Normalization')
        end

            %% Appearance (Plot Histograms)
            red_h.FaceColor = [1 0 0];
            red_h.FaceAlpha = 0.6;    
            green_h.FaceColor = [0 0.7 0];
            green_h.FaceAlpha = 0.4;

            hTitle  = title (sprintf('Histograms - Day %s, Mouse %s', num2str(RFP_Day), num2str(RFP_MouseNo)));
            hXLabel = xlabel('Cells'                              );
            hYLabel = ylabel('Fraction of total count'            );
            %hText1 = sprintf('Day = %d pixels',Day);
            %hText   = text(60000, 160, ...
              %sprintf('\\it{Day = %d}', Day));
            
            % 'Cells' Axis
            set( gca                                                        , ...  
                'FontSize'   , 18                                           , ...
                'Position',[0.13 0.329171396140749 0.775 0.595828603859251] , ...
                'FontName'   , 'Helvetica'                                  );

            set([hTitle, hXLabel, hYLabel], ...
                'FontName'   , 'AvantGarde');
            set([hXLabel, hYLabel]  , ...
                'FontSize'   , 18          );
            set( hTitle                    , ...
                'FontSize'   , 18          , ...
                'FontWeight' , 'bold'      );
            xlim([0 500])

            % um^2 Axis
            area_ax=axes('Position', [0.1310183299389 0.206567106398069 0.799999999999999 0]);
            set(area_ax,'Units','normalized');
            set(area_ax,'Color',[0 0 0]);
            set(area_ax,'xlim',[0 (500)*cell_area_in_pixels*(7.25e-6)]);
            xlabel(area_ax,'Area (mm^2)', 'FontSize', 14)


            set(gca, ...
              'Box'         , 'on'     , ...
              'TickDir'     , 'out'     , ...   %'TickLength'  , [.01 .01] , ...
              'XMinorTick'  , 'off'      , ...
              'YMinorTick'  , 'off'      , ...
              'YGrid'       , 'on'      , ...
              'XGrid'       , 'on'      , ...
              'XColor'      , [.0 .0 .0], ...
              'YColor'      , [.0 .0 .0], ...   %'YTick'       , 0:YaxisMax/10:0.6, ...
              'FontSize'    , 18       , ...
              'LineWidth'   , 1         );
          
            set(gcf,'units','points','position',[x0,y0,width,height])
            
            hold off

    %% Is median Red colony size greater than Green colony size?
    % Wilcoxon Rank Sum Test  (is median Red colony area greater than green?)
    [p(i), h(i)] = ranksum(RFP_lung_areas, GFP_lung_areas, 'tail', 'right');
    
        
    %% Save Images

    % Create title:
    
    %filename = strcat('L_', 'D_', num2str(RFP_Day), '_M_', num2str(RFP_MouseNo), '_Norm_', num2str(Normalization));
    %saveas(gcf, filename, 'tif')
    
    %% Fit Average Distribution and Consolidated Histogram
    
    % Average Distributions
    x = 10:100:10000;
    
    weibull_red_dist = fitdist(RFP_lung_areas, 'Weibull');
    dist_red_y(i-1,:) = pdf(weibull_red_dist, x);
    figure(9)
    
    plot(x, dist_red_y, 'Linewidth', 2, 'Color', 'r')
    hold on
    weibull_green_dist = fitdist(GFP_lung_areas, 'Weibull');
    dist_green_y(i-1, :) = pdf(weibull_green_dist, x);
    figure(9)
    
    plot(x, dist_green_y, 'Linewidth', 2, 'Color', 'g')
    set(gcf,'units','points','position',[x0,y0,width,height])
    
    % Consolidated Histogram
    RFP_lung_areas_combined = [RFP_lung_areas_combined; RFP_lung_areas];
    GFP_lung_areas_combined = [GFP_lung_areas_combined; GFP_lung_areas];
    
    
    end
    
    % Get Mean and Errorbars
    % This figure plots the average probability density functions for the
    % red and green mets. The probability density functions are averaged
    % over all the images. 
    
    mean_red_dist = mean(dist_red_y);
    std_red_dist = std(dist_red_y);
    figure(11)
    eplot_red = errorbar(x, mean_red_dist, std_red_dist, 'r');
    hold on
    mean_green_dist = mean(dist_green_y);
    std_green_dist = std(dist_green_y);
    figure(11)
    eplot_green = errorbar(x, mean_green_dist, std_green_dist, 'g');
    hold on
    xlim([0 500])
    set(gcf,'units','points','position',[x0,y0,width,height])
    ylim([0 0.015])
    
            %% Appearance (Fit Average Distribution)
    
    
            eplot_red.Bar.LineStyle = 'solid';
            eplot_red.Bar.LineWidth = 1;
            eplot_red.Line.LineWidth = 4;

            eplot_green.Bar.LineStyle = 'solid';
            eplot_green.Bar.LineWidth = 1;
            eplot_green.Line.LineWidth = 4;


            set(eplot_red                     , ...
            'Color'           , [1 0 0]       , ...
            'LineWidth'       , 1.            , ...
            'Marker'          , 'o'           , ...
            'MarkerSize'      , 1             , ...
            'MarkerEdgeColor' , [1 .2 .2]     , ...
            'MarkerFaceColor' , [0.8 0 0]     );

            set(eplot_green                   , ...
            'Color'           , [0 0.5 0]     , ...
            'LineWidth'       , 1.            , ...
            'Marker'          , 'o'           , ...
            'MarkerSize'      , 1             , ...
            'MarkerEdgeColor' , [.2 1 .2]     , ...
            'MarkerFaceColor' , [0 .5 0]      );

            hTitle  = title ('Lung Colony Area PDFs'       );
            hXLabel = xlabel('Cells'                           );
            hYLabel = ylabel('Probability Density'               );

            % 'Cells' Axis
            set( gca                                                        , ...  
                'FontSize'   , 18                                           , ...
                'Position',[0.13 0.329171396140749 0.775 0.595828603859251] , ...
                'FontName'   , 'Helvetica'                                  );

            set([hTitle, hXLabel, hYLabel], ...
                'FontName'   , 'AvantGarde');
            set([hXLabel, hYLabel]  , ...
                'FontSize'   , 18          );
            set( hTitle                    , ...
                'FontSize'   , 18          , ...
                'FontWeight' , 'bold'      );

            % um^2 Axis
            area_ax=axes('Position', [0.1310183299389 0.206567106398069 0.799999999999999 0]);
            set(area_ax,'Units','normalized');
            set(area_ax,'Color',[0 0 0]);
            set(area_ax,'xlim',[0 (500)*cell_area_in_pixels*(7.25e-6)]);
            xlabel(area_ax,'Area (mm^2)', 'FontSize', 14)


            set(gca, ...
              'Box'         , 'on'     , ...
              'TickDir'     , 'out'     , ...   %'TickLength'  , [.01 .01] , ...
              'XMinorTick'  , 'off'      , ...
              'YMinorTick'  , 'off'      , ...
              'YGrid'       , 'on'      , ...
              'XGrid'       , 'on'      , ...
              'XColor'      , [.3 .3 .3], ...
              'YColor'      , [.3 .3 .3], ...   %'YTick'       , 0:YaxisMax/10:0.6, ...
              'FontSize'    , 18       , ...
              'LineWidth'   , 1         );
    
    
    %% Consolidated Histograms Continued
    % This figure presents a single histogram consisting of all Red and
    % Green mets combined. The mets across all the images are added and
    % the total is plotted.

    figure(12)
    allred_h = histogram(RFP_lung_areas_combined, edges, 'Normalization', 'pdf');
    hold on
    allgreen_h = histogram(GFP_lung_areas_combined, edges, 'Normalization', 'pdf');
    xlim([0 800])
    
    [p2, h2] = ranksum(RFP_lung_areas_combined, GFP_lung_areas_combined, 'tail', 'left');
    
    %% Appearance (Consolidated Lung Areas)
            allred_h.FaceColor = [1 0 0];
            allred_h.FaceAlpha = 0.6;    
            allgreen_h.FaceColor = [0 0.7 0];
            allgreen_h.FaceAlpha = 0.4;

            hTitle  = title (sprintf('Histograms - Consolidated')   );
            hXLabel = xlabel('Cells'                                );
            hYLabel = ylabel('Probability Density'             );
            %hText1 = sprintf('Day = %d pixels',Day);
            %hText   = text(60000, 160, ...
              %sprintf('\\it{Day = %d}', Day));

            set( gca                       , ...
                'FontName'   , 'Helvetica' );
            set([hTitle, hXLabel, hYLabel], ...
                'FontName'   , 'AvantGarde');
            set([hXLabel, hYLabel]  , ...
                'FontSize'   , 18          );
            set( hTitle                    , ...
                'FontSize'   , 18          , ...
                'FontWeight' , 'bold'      );
            %plot(X_midpt', y, 'Linewidth', 2)
            
                        % 'Cells' Axis
            set( gca                                                        , ...  
                'FontSize'   , 18                                           , ...
                'Position',[0.13 0.329171396140749 0.775 0.595828603859251] , ...
                'FontName'   , 'Helvetica'                                  );

            set([hTitle, hXLabel, hYLabel], ...
                'FontName'   , 'AvantGarde');
            set([hXLabel, hYLabel]  , ...
                'FontSize'   , 18          );
            set( hTitle                    , ...
                'FontSize'   , 18          , ...
                'FontWeight' , 'bold'      );

            % um^2 Axis
            area_ax=axes('Position', [0.1310183299389 0.206567106398069 0.799999999999999 0]);
            set(area_ax,'Units','normalized');
            set(area_ax,'Color',[0 0 0]);
            set(area_ax,'xlim',[0 (800)*cell_area_in_pixels*(7.25e-6)]);
            xlabel(area_ax,'Area (mm^2)', 'FontSize', 18)
                        set(gca, ...
              'Box'         , 'on'     , ...
              'TickDir'     , 'out'     , ...   %'TickLength'  , [.01 .01] , ...
              'XMinorTick'  , 'off'      , ...
              'YMinorTick'  , 'off'      , ...
              'YGrid'       , 'on'      , ...
              'XGrid'       , 'on'      , ...
              'XColor'      , [.3 .3 .3], ...
              'YColor'      , [.3 .3 .3], ...   %'YTick'       , 0:YaxisMax/10:0.6, ...
              'FontSize'    , 18       , ...
              'LineWidth'   , 1         );

            hold off            
            
            
    %% Fit Individual distributions:
    % This graph compares the colony size distributions between two lungs.
    % The user can manually select the lungs they wish to compare below.
    % The numbers are the order of lungs in the variables 'RFP_data' and
    % 'GFP_data' (type them in the console and press enter to see the 'day'
    % and 'mouse number'.
    Lung_No_1 = 1; 
    Lung_No_2 = 2;
    figure(13)
    plot(x, dist_red_y(Lung_No_1, :), 'r', 'Linewidth', 4)
    hold on
    plot(x, dist_green_y(Lung_No_1, :), 'g', 'Linewidth', 4)
    
    
    plot(x, dist_red_y(Lung_No_2, :), 'r', 'Linewidth', 4, 'LineStyle', ':')
    
    plot(x, dist_green_y(Lung_No_2, :), 'g', 'Linewidth', 4, 'LineStyle', ':')
    xlim([0 1000])
    ylim([0 15.0e-3])
    
    %% Appearance (Individual Distributions)
    hTitle  = title ('Colony Size Distribution'       );
            hXLabel = xlabel('Cells'                           );
            hYLabel = ylabel('Probability Density'               );

            % 'Cells' Axis
            set( gca                                                        , ...  
                'FontSize'   , 18                                           , ...
                'Position',[0.13 0.329171396140749 0.775 0.595828603859251] , ...
                'FontName'   , 'Helvetica'                                  );

            set([hTitle, hXLabel, hYLabel], ...
                'FontName'   , 'AvantGarde');
            set([hXLabel, hYLabel]  , ...
                'FontSize'   , 18          );
            set( hTitle                    , ...
                'FontSize'   , 18          , ...
                'FontWeight' , 'bold'      );

            % um^2 Axis
            area_ax=axes('Position', [0.1310183299389 0.206567106398069 0.799999999999999 0]);
            set(area_ax,'Units','normalized');
            set(area_ax,'Color',[0 0 0]);
            set(area_ax,'xlim',[0 (1000)*cell_area_in_pixels*(7.25e-6)]);
            xlabel(area_ax,'Area (mm^2)', 'FontSize', 14)


            set(gca, ...
              'Box'         , 'on'     , ...
              'TickDir'     , 'out'     , ...   %'TickLength'  , [.01 .01] , ...
              'XMinorTick'  , 'off'      , ...
              'YMinorTick'  , 'off'      , ...
              'YGrid'       , 'on'      , ...
              'XGrid'       , 'on'      , ...
              'XColor'      , [.3 .3 .3], ...
              'YColor'      , [.3 .3 .3], ...   %'YTick'       , 0:YaxisMax/10:0.6, ...
              'FontSize'    , 18       , ...
              'LineWidth'   , 1         );

    
end
