function [c2_output] = c2_main(radar_input, eo_input, flight_input)
% The entry point for C2 sub-system.
%

%% Expected input
% From the radar
time = 0; % the time in seconds
radar_track(1).position = [0 0]; % position of a track in global (x, y) coordinate, unit: pixel
radar_track(1).velocity = [0 0]; % velocity of a track in global (x, y) coordinate, unit: pixel/second
% you can have more tracks

% From the EO
time = 0; % the time in seconds
valid_target = logical(false); % human validated valid target declaration
eo_image = zeros(50, 50); % the 50 by 50 gray scale EO image

% From Flight
time = 0; % the time in seconds
p8_position = [0 0]; % position of p8 in global (x, y) coordinate, unit: pixel
h60_position = [0 0]; % position of h60 in global (x, y) coordinate, unit: pixel

%% C2 implemenation
disp('You are in c2_main().');


%% The output
c2_output = C2_Output_Interface; % The outputs are defined in 'C2_Output_Interface.m'
