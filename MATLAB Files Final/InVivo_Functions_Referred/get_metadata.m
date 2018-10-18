function [day, mouse] = get_metadata(z, list)
% This function gets the day and mouse number of the folder that is
% currently being processed. Based on our default naming convention:
% XXX_d_40_m_05_s02, where d = day, m = mouse no, s = set, XXX may be any
% information.


str_index = findstr(lower(list(z).name), '_d_');
day = str2num(strcat(list(z).name(str_index+3), list(z).name(str_index+4)));
str_index = findstr(lower(list(z).name), '_m_');
mouse = str2num(strcat(list(z).name(str_index+3), list(z).name(str_index+4)));