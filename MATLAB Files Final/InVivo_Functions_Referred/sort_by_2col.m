function sorted_data = sort_by_2col(exceldata, col1, col2, title, title1, title2)
% This function takes in data from the spreadsheet created by 'L_CombSeg' 
% scripts and returns a cell where data has been sorted based on the
% category in column number 'col'.


col1_unique = unique(exceldata(:, col1));       % Get unique values
col2_unique = unique(exceldata(:, col2));

sort_column1 = exceldata(:, col1);
sort_column2 = exceldata(:, col2);

sorted_data = [{title, title1, title2}];%, length(col1_unique));  % Final cell array


for i = 1:length(col1_unique)                % For every col1 unique
    for j = 1:length(col2_unique)            % For every col2 unique
        
        % Initialize    
        temp_data = [];
        temp_data = exceldata(sort_column1 == col1_unique(i) &       ...
                              sort_column2 == col2_unique(j), 3);

        sorted_data_temp{1, 1} = temp_data;
        sorted_data_temp{1, 2} = col1_unique(i);
        sorted_data_temp{1, 3} = col2_unique(j);
        sorted_data = [sorted_data; sorted_data_temp];  % Add another row
    end    
end
end
