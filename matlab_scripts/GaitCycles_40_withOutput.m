clc;
clear;
warning('off');

%files_path = [pwd, '\Svonko_NORAXON_Data\CSV_Files'];
files_path = 'C:\Users\svonk\Desktop\0_Treadmill_COP\Svonko_NORAXON_Data\CSV_Files';

% get name from folders
path_info = dir(files_path);
path_info = path_info(3:end); % this is to remove the first two elements: "." and ".." [likewise cd command]

% now let us put all the folders inside a cell
path_cell = cell(size(path_info,1),1);
fullpath_cell = cell(size(path_info,1),1);

for i = 1:size(path_info,1)
    path_cell{i,1} = path_info(i).name;
    fullpath_cell{i,1} = [files_path, '\', path_info(i).name];
end

%path_cell{1} %here I havo only the subfolder name (using this for the plot title)
%fullpath_cell{1} %here I have the path till the subfolder

gait_cycles_40_cell = cell(size(path_info,1),2);

for j = 1:size(fullpath_cell, 1)
    csv_file_name = dir(fullpath_cell{j});
    csv_file_name = csv_file_name(3:end);
    
    csv_file = [csv_file_name.folder, '\', csv_file_name.name];
    T = readtable(csv_file);
    
    X = T.RTFootAccelSensorX_mG(1:size(T.RTFootAccelSensorX_mG));
    Y = T.RTFootAccelSensorY_mG(1:size(T.RTFootAccelSensorY_mG));
    Z = T.RTFootAccelSensorZ_mG(1:size(T.RTFootAccelSensorZ_mG));
    
    % Butterworth filter
    %zero-lag filtered using a 4th-order low-pass Butterworth filter with a cut-off frequency of 4 Hz.
    [b,a] = butter(4,4/(100/2),"low");
    X = filtfilt(b,a,X);
    Y = filtfilt(b,a,Y);
    Z = filtfilt(b,a,Z);
    
    V = vecnorm([X, Y, Z]')';

    [pks,locs] = findpeaks(V,'MinPeakProminence', 200, 'MinPeakDistance', 80);
    
    pks_gait_cycle = pks(2:41);
    locs_gait_cycle = locs(2:41);
       
    gait_cycles_40_cell{j,1} = T.Time_s(locs_gait_cycle(end));
    gait_cycles_40_cell{j,2} = path_info(j).name;
    
    index_to_find = find(T.Time_s(:) == gait_cycles_40_cell{j,1});

    T_new = T;

    T_new(index_to_find+1:end,:) = [];
    
    output_path = ['C:\Users\svonk\Desktop\0_Treadmill_COP\Svonko_NORAXON_Data\CSV_Files_FinalDataset\', path_info(j).name, '\', csv_file_name.name];
    
    writetable(T_new, output_path, 'Delimiter', ';');
   
end
