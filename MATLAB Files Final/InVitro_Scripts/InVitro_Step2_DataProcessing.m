%% Documentation

% This script analyzes ki67 image data from the distributions

close all
clear 

%% Obtain and Sort Data from spreadsheet

all_wells = {'A1', 'A2', 'A3', 'B1', 'B2', 'B3'};

number_of_wells = length(all_wells);

for i = 1:number_of_wells % This for loop obtains all well data and stores them in a cell
    
    well = all_wells{i}
    
    % Obtain data from spreadsheet
    filename = strcat(well, '_data.xlsx');
    num = xlsread(filename);
    data_all{i} = num;
end

%% Run Loop over each well

consolidated_cellcounts = [];
consolidated_areas =[];
for i = 1:number_of_wells;
    
        % Get data of well{i}
    well_data = data_all{i};

        % Clean Data
    well_data(well_data(:, 2) > 1000, :) = []; % Filter by cell count
    well_data(well_data(:, 2) < 5, :) = []; % Filter by cell count
    well_data(well_data(:, 6) == nan, :) = []; % Remove colonies that have redfrac of infinity, i.e no signal from red or green masks (artifacts)

    %% Separate Red and Green data
        % Green Colonies

    well_data_temp = well_data;

    well_data_temp(well_data_temp(:, 6) > 0.6, :) = [];  % Remove red colonies, keep green

    Green_colony.Areas = well_data_temp(:, 1);
    Green_colony.Cell_counts = well_data_temp(:, 2);
    Green_colony.KI67_frac = well_data_temp(:, 5);
    Green_colony.Red_frac = well_data_temp(:, 6);
    %xlswrite(strcat(all_wells{i}, '_Green.xlsx'), [Green_colony.KI67_frac]);
        % Red Colonies
    clear well_all_temp

    well_data_temp = well_data;

    well_data_temp(well_data_temp(:, 6) < 0.6, :) = [];  % Remove green colonies, keep red

    Red_colony.Areas = well_data_temp(:, 1);
    Red_colony.Cell_counts = well_data_temp(:, 2);
    Red_colony.KI67_frac = well_data_temp(:, 5);
    Red_colony.Red_frac = well_data_temp(:, 6);
    %xlswrite(strcat(all_wells{i}, '_Red.xlsx'), [Red_colony.KI67_frac]);
    
    %% Fit Colony Size (Cell Count) distributions to each well
    
    x = 0:5:200;
    % Get distribution parameters
    weibull_red_dist    = fitdist([Red_colony.Cell_counts], 'Weibull');
    weibull_green_dist  = fitdist([Green_colony.Cell_counts], 'Weibull');
    
    % Get Distribution pdf y-values
    dist_red_y(:,i)     = pdf(weibull_red_dist, x);
    dist_green_y(:,i)   = pdf(weibull_green_dist, x);
    
%% Fit ki67 dsitributions to each well

    x2 = 0.0:0.1:1;
    
    % Get distribution parameters
    Red_ki_temp = [Red_colony.KI67_frac];
    Green_ki_temp = [Green_colony.KI67_frac];
    Red_ki_temp(Red_ki_temp == 0) = 0.001;
    Green_ki_temp(Green_ki_temp == 0) = 0.001;
    
    ki67_red_dist    = fitdist(Red_ki_temp, 'Weibull');
    ki67_green_dist  = fitdist(Green_ki_temp, 'Weibull');
    
    % Get Distribution pdf y-values
    dist_red_ki_y(:,i)     = pdf(ki67_red_dist, x2);
    dist_green_ki_y(:,i)   = pdf(ki67_green_dist, x2);
    


    %% Plot Individual Ki67 frac histograms
    % Set Normalization type
    Normalization = 2;
    edges = 0:0.05:1;
    
        figure
        if Normalization == 0

            %% No Normalization
            % Create histograms

            red_h = histogram([Red_colony.KI67_frac], edges);
            hold on
            green_h = histogram([Green_colony.KI67_frac], edges);

            %% R + G = 1
        elseif Normalization == 1 
            red_counts = histcounts([Red_colony.KI67_frac], edges);
            green_counts = histcounts([Green_colony.KI67_frac], edges);

            red_counts = red_counts/Total_Met_Count;
            green_counts = green_counts/Total_Met_Count;
            
            midpts = edges + (edges(2)/2); midpts(end) = []; %Sort edges to be midpoints

            red_h = bar(midpts, red_counts, 1, 'r');
            hold on
            green_h = bar(midpts, green_counts, 1, 'r');

            %% R = 1 and G = 1
        elseif Normalization == 2

            red_h = histogram([Red_colony.KI67_frac], edges, 'Normalization', 'probability');
            hold on
            green_h = histogram([Green_colony.KI67_frac], edges,  'Normalization', 'probability');
        else
            disp('Incorrect input for Normalization')
        end

            %% Appearance (Plot Histograms)
            red_h.FaceColor = [1 0 0];
            red_h.FaceAlpha = 0.6;    
            green_h.FaceColor = [0 0.7 0];
            green_h.FaceAlpha = 0.4;

            hTitle  = title ('');
            hXLabel = xlabel('Fraction of nuclei expressing Ki-67 in a given colony'                              );
            hYLabel = ylabel('Fraction of total colonies'            );
            %hText1 = sprintf('Day = %d pixels',Day);
            %hText   = text(60000, 160, ...
              %sprintf('\\it{Day = %d}', Day));
 
            set( gca                                                        , ...  
                'FontSize'   , 24                                           , ...
                'FontName'   , 'Helvetica'                                  );

            set([hTitle, hXLabel, hYLabel], ...
                'FontName'   , 'AvantGarde');
            set([hXLabel, hYLabel]  , ...
                'FontSize'   , 24          );
            set( hTitle                    , ...
                'FontSize'   , 24          , ...
                'FontWeight' , 'bold'      );

            
            hold off
    
%% Plot Cell Counts vs Area

consolidated_cellcounts = [consolidated_cellcounts; well_data(:,2)];
consolidated_areas = [consolidated_areas; well_data(:,1)];
if i == number_of_wells
    
figure(20)
plot(consolidated_areas, consolidated_cellcounts, '.b')
fit_line = polyfit(consolidated_areas, consolidated_cellcounts, 2);
hold on
plot([5:1000:60000], polyval(fit_line, [5:1000:60000]), 'LineStyle', '-',  'Color' ,'black')

    %% Appearance
            hTitle  = title ('Cell to Pixels ratio');
            hXLabel = xlabel('Colony Area (Pixels)'                              );
            hYLabel = ylabel('Colony Cell Count'            );
            %hText1 = sprintf('Day = %d pixels',Day);
            %hText   = text(60000, 160, ...
              %sprintf('\\it{Day = %d}', Day));
            
            % 'Cells' Axis
            set( gca                                                        , ...  
                'FontSize'   , 18                                           , ...
                'FontName'   , 'Helvetica'                                  );

            set([hTitle, hXLabel, hYLabel], ...
                'FontName'   , 'AvantGarde');
            set([hXLabel, hYLabel]  , ...
                'FontSize'   , 18          );
            set( hTitle                    , ...
                'FontSize'   , 18          , ...
                'FontWeight' , 'bold'      );
            xlim([0 60000]); ylim([0 1500]);
else
    
end





end

%% Individual Plots of Area/ Cell Counts
figure
for i = 1:number_of_wells
    
    
    if i < 4 %The code currently assumes that the first three wells belong to row A (A1, A2, A3)
        
    plot(x, dist_red_y(:, i), 'Linewidth', 2, 'Color', 'r')
    hold on    
    plot(x, dist_green_y(:, i), 'Linewidth', 2, 'Color', 'g')
    %set(gcf,'units','points','position',[x0,y0,width,height])
    
    else
        
    plot(x, dist_red_y(:, i), 'Linewidth', 2, 'Color', 'r', 'LineStyle', '--')
        
    plot(x, dist_green_y(:, i), 'Linewidth', 2, 'Color', 'g', 'LineStyle', '--')
    end
        
    %% Appearance
               hTitle  = title ('Colony Size Distributions');
            hXLabel = xlabel('Cells'                              );
            hYLabel = ylabel('Probability Density'            );
            %hText1 = sprintf('Day = %d pixels',Day);
            %hText   = text(60000, 160, ...
              %sprintf('\\it{Day = %d}', Day));
            
            % 'Cells' Axis
            set( gca                                                        , ...  
                'FontSize'   , 24                                           , ...
                'FontName'   , 'Helvetica'                                  );

            set([hTitle, hXLabel, hYLabel], ...
                'FontName'   , 'AvantGarde');
            set([hXLabel, hYLabel]  , ...
                'FontSize'   , 24          );
            set( hTitle                    , ...
                'FontSize'   , 24          , ...
                'FontWeight' , 'bold'      );
            
end




%% Group Plots of Ki67 distributions
figure
for i = 1:number_of_wells
    
        if i < 4 %The code currently assumes that the first 3 wells belong to row A.
        
    plot(x2, dist_red_ki_y(:, i), 'Linewidth', 4, 'Color', 'r')
    hold on    
    plot(x2, dist_green_ki_y(:, i), 'Linewidth', 4, 'Color', 'g')
    %set(gcf,'units','points','position',[x0,y0,width,height])
    
    else
        
    plot(x2, dist_red_ki_y(:, i), 'Linewidth', 4, 'Color', 'r', 'LineStyle', '--')
        
    plot(x2, dist_green_ki_y(:, i), 'Linewidth', 4, 'Color', 'g', 'LineStyle', '--')
        end
    
            %% Appearance
               hTitle  = title ('KI67 Distributions');
            hXLabel = xlabel('Fractional coverage per colony'                              );
            hYLabel = ylabel('Probability Density'            );
            %hText1 = sprintf('Day = %d pixels',Day);
            %hText   = text(60000, 160, ...
              %sprintf('\\it{Day = %d}', Day));
            
            % 'Cells' Axis
            set( gca                                                        , ...  
                'FontSize'   , 24                                           , ...
                'FontName'   , 'Helvetica'                                  );

            set([hTitle, hXLabel, hYLabel], ...
                'FontName'   , 'AvantGarde');
            set([hXLabel, hYLabel]  , ...
                'FontSize'   , 24          );
            set( hTitle                    , ...
                'FontSize'   , 24          , ...
                'FontWeight' , 'bold'      );
    
end

%% Average Plots of KI67 distribution

ki_dist_red_A = dist_red_ki_y(:,1:3); % The code currently assumes the first three wells are from row A (A1, A2, A3)
ki_dist_red_B = dist_red_ki_y(:,4:6); % The code currently assumes that the second three wells are from row B (B1, B2, B3)
ki_dist_green_A = dist_green_ki_y(:,1:3); % The same applies to the green colonies
ki_dist_green_B = dist_green_ki_y(:,4:6);

mean_ki_dist_red_A = mean(ki_dist_red_A, 2); sd_ki_dist_red_A = std(ki_dist_red_A,0, 2);
mean_ki_dist_red_B = mean(ki_dist_red_B, 2); sd_ki_dist_red_B = std(ki_dist_red_B,0, 2);

mean_ki_dist_green_A = mean(ki_dist_green_A, 2); sd_ki_dist_green_A = std(ki_dist_green_A, 0,2);
mean_ki_dist_green_B = mean(ki_dist_green_B, 2); sd_ki_dist_green_B = std(ki_dist_green_B, 0,2);

figure, 
hold on
pr = errorbar(x2,mean_ki_dist_red_A, sd_ki_dist_red_A/3, '-r'); % Divided by 3 gives standard error
pg = errorbar(x2,mean_ki_dist_green_A, sd_ki_dist_green_A/3, '-g');

%prc = errorbar(x2,mean_ki_dist_red_B, sd_ki_dist_red_B/3, '-r');
%pgc = errorbar(x2,mean_ki_dist_green_B, sd_ki_dist_green_B/3, '-g');

%% Figure Properties

ylim([0 4.5])
  pr.Bar.LineStyle = 'solid';
            pr.Bar.LineWidth = 3;
            pr.Line.LineWidth = 3;

            pg.Bar.LineStyle = 'solid';
            pg.Bar.LineWidth = 3;
            pg.Line.LineWidth = 3;


            set(pr                     , ...
            'Color'           , [1 0 0]       , ...
            'LineWidth'       , 1.            , ...
            'Marker'          , 'o'           , ...
            'MarkerSize'      , 1             , ...
            'MarkerEdgeColor' , [1 .2 .2]     , ...
            'MarkerFaceColor' , [0.8 0 0]     );

            set(pg                   , ...
            'Color'           , [0 0.5 0]     , ...
            'LineWidth'       , 1.            , ...
            'Marker'          , 'o'           , ...
            'MarkerSize'      , 1             , ...
            'MarkerEdgeColor' , [.2 1 .2]     , ...
            'MarkerFaceColor' , [0 .5 0]      );

            hTitle  = title (''       );
            hXLabel = xlabel('Fractional Coverage'                           );
            hYLabel = ylabel('Probability Density'               );
                        
            set( gca                                                        , ...
                'FontSize'   , 24                                           , ...
                'FontName'   , 'Helvetica'                                  );

            set([hTitle, hXLabel, hYLabel], ...
                'FontName'   , 'AvantGarde');
            set([hXLabel, hYLabel]  , ...
                'FontSize'   , 24          );
            set( hTitle                    , ...
                'FontSize'   , 24          , ...
                'FontWeight' , 'bold'      );