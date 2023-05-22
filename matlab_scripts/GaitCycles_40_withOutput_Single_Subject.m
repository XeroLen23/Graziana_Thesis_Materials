clc;
clear;
warning('off');

file_path = 'C:\Users\svonk\Desktop\_Drop_IMU_Columns\Svonko_NORAXON_Data\CSV_Files\2r2Q29Wk\2r2Q29Wk_TreadmillW$_NOR.csv';
    
T = readtable(file_path);
    
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

gait_cycles_40 = T.Time_s(locs_gait_cycle(end));

fig = figure();
fig.WindowState = 'maximized';

plot(V(1:locs_gait_cycle(end))); hold on;
plot(locs_gait_cycle(end), pks_gait_cycle(end), 'or');

index_to_find = find(T.Time_s(:) == gait_cycles_40);

T_new = T;

T_new(index_to_find+1:end,:) = [];

X_new = T_new.RTFootAccelSensorX_mG(1:size(T_new.RTFootAccelSensorX_mG));
Y_new = T_new.RTFootAccelSensorY_mG(1:size(T_new.RTFootAccelSensorY_mG));
Z_new = T_new.RTFootAccelSensorZ_mG(1:size(T_new.RTFootAccelSensorZ_mG));

% Butterworth filter
%zero-lag filtered using a 4th-order low-pass Butterworth filter with a cut-off frequency of 4 Hz.
X_new = filtfilt(b,a,X_new);
Y_new = filtfilt(b,a,Y_new);
Z_new = filtfilt(b,a,Z_new);

V_new = vecnorm([X_new, Y_new, Z_new]')';

[pks_new,locs_new] = findpeaks(V_new,'MinPeakProminence', 200, 'MinPeakDistance', 80);

fig = figure();
fig.WindowState = 'maximized';

plot(V_new); hold on;
plot(locs_new(2:end), pks_new(2:end), 'or');

% writetable(T_new, 'T_new.csv', 'Delimiter', ';');
