function [c2_output] = c2_main(time, dt, radar_input, eo_input, flight_input)
% The entry point for C2 sub-system.
%
if(nargin==0)
   disp('BLACK PEARL - Command and Control System 1.1');
   return;
end

%% Expected input
% From LSI
% time = 0; % simulation time (starting from 0, in seconds)
% dt = 60; % simulatino time step (seconds/step)

% From the radar
% radar_track(1).position = [0 0]; % position of a track in global (x, y) coordinate, unit: pixel
% radar_track(1).velocity = [0 0]; % velocity of a track in global (x, y) coordinate, unit: pixel/second
% % you can have more tracks
%
% % From the EO
% eo_input.valid_target = logical(false); % human validated valid target declaration
%
% % From Flight
% flight_input.p8_position = [0 0]; % position of p8 in global (x, y) coordinate, unit: pixel
% flight_input.h60_position = [0 0]; % position of h60 in global (x, y) coordinate, unit: pixel

%%
radar_track = radar_input;
valid_target = eo_input.valid_target;
p8_position = flight_input.p8_position;
h60_position = flight_input.h60_position;

persistent track_id;
if(time == 0)
   track_id = 0;
end

%% C2 implemenation

% A2.1 Analyze radar data
% Compare speed of track
pirate_speed = 1/120;
pirate_pos = [];
for k = 1:length(radar_input)
   speed(k) = norm(radar_track(k).vel);
   track_name(k) = radar_track(k).id;
   age(k) = time - radar_track(k).initiation_time;
   age(k) = size(radar_track(k).history, 1);
end

% find the fastest one
if(length(radar_input))
    potential_inx = find(speed > pirate_speed*0.9);
    if(length(potential_inx) > 0)
        % prefer the older one
        [dummy oldest_inx] = max(age(potential_inx));
        inx = potential_inx(oldest_inx);
        % Determine pirate location
        pirate_pos = radar_track(inx).pos;
        pirate_vel = radar_track(inx).vel;
        if(radar_track(inx).id ~= track_id)
            track_id = radar_track(inx).id;
 %           disp(sprintf('track id: %.0f', track_id));
        end
    end

%     [max_speed max_inx] = max(speed);
%
%     if(max_speed > pirate_speed*0.9) % Need to be fast enough
%         % Determine pirate location
%         pirate_pos = radar_track(max_inx).pos;
%         pirate_vel = radar_track(max_inx).vel;
%         if(radar_track(max_inx).id ~= track_id)
%             track_id = radar_track(max_inx).id;
% %            disp(sprintf('track id: %.0f', track_id));
%         end
%     end
    figure(99);
    bar(track_name, speed);
    hold on;
    plot(track_name, 0.9*pirate_speed*ones(length(track_name), 1), 'r-');
    hold off;
    xlabel('Track ID');
    ylabel('Track Speed (pixel/s)');
end

% A2.2 Generate valid target flag
% This happens in the end

% A2.3 Direct H60

% A2.3.1 Determine H60 Flight Strategy
if(isempty(pirate_pos)) % No pirate found
    h60_strategy = 'search';

else
    h60_strategy = 'intercept';
end

% A2.3.2 Calculate H60 Waypoint
switch h60_strategy
    case 'search'
        h60_waypoint = p8_position; % H60 will follow P8.
        % maybe it shouldn't go too far north

    case 'intercept'
        if(norm(pirate_vel) == 0 )
            h60_waypoint = pirate_pos; % simple tail chase
        else
            % we can do better with proportional navigation
            % predict where the pirate will be in the next time step
            gain = norm(h60_position-pirate_pos) * 0.5; % navigation gain
            gain = min(gain, 10);
            pirate_speed = 1/120; % pixel/sec
            next_pirate_pos = pirate_pos + pirate_vel/norm(pirate_vel)*pirate_speed*dt*gain;
            h60_waypoint = next_pirate_pos;
        end
    otherwise
        warning('Undefined H60 strategy!');
end

% A2.4 Direct P8

% A2.4.1
if(isempty(pirate_pos)) % No pirate found
    p8_strategy = 'search';
else
    p8_strategy = 'follow';
end

% A2.4.2 Calculate H60 Waypoint
search_waypoints = [297 628 646 582 464; ...
                    405 323 524 675 840];
search_waypoints = search_waypoints';
persistent last_waypoint;
if(time == 0)
    last_waypoint = search_waypoints(1, :);
end
switch p8_strategy
    case 'search'
        % Need to know the current position
        d1 = norm(search_waypoints(1, :) - p8_position);
        d2 = norm(search_waypoints(2, :) - p8_position);
        if(d1 < 2)
            p8_waypoint = search_waypoints(2, :);
            last_waypoint = p8_waypoint;
        elseif(d2 < 2)
            p8_waypoint = search_waypoints(1, :);
            last_waypoint = p8_waypoint;
        else
            p8_waypoint = last_waypoint;
        end
    case 'follow'
        pirate_speed = 1/120; % pixel/sec
        if(norm(pirate_vel) == 0)
           next_pirate_pos = pirate_pos;
        else
            next_pirate_pos = pirate_pos + pirate_vel/norm(pirate_vel)*pirate_speed*dt;
        end
        p8_waypoint = next_pirate_pos;
    otherwise
        warning('Undefined P8 strategy!');
end


%% The output
c2_output = C2_Output_Interface; % The outputs are defined in 'C2_Output_Interface.m'
c2_output.valid_target = valid_target;
c2_output.p8_waypoint = p8_waypoint;
c2_output.h60_waypoint = h60_waypoint;