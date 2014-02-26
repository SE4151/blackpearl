%%
addpath('../environment/');
load('pirate_boat.mat');
pirate_ref = double(map);
clear map;

% parametrs
p8_speed = 1/10; % pixel/sec
h60_speed = 1/30; % pixel/sec
pirate_speed = 1/120; % pixel/sec
launch_pos = [577 406];
search_waypoints = [297 628 646 582 464; ...
                    405 323 524 675 840];
search_waypoints = search_waypoints';
p8_pos = launch_pos;
h60_pos = launch_pos;
p8_waypoint = search_waypoints(1, :);
h60_waypoint = p8_waypoint;


dt = 100; % time step
for t = 0:dt:5000
    % Generate environment map
    [global_map, eo_map, boarded, pirate_pos] = Environment(t);

    % Flight
    % Fly P8
    if(norm(p8_waypoint-p8_pos) <= p8_speed*dt)% check to make sure we don't fly pass the waypoint
        p8_pos = p8_waypoint;
    else
        p8_pos = p8_pos + (p8_waypoint-p8_pos)./norm(p8_waypoint-p8_pos).*p8_speed*dt;
    end
    % Fly H60
    if(norm(h60_waypoint-h60_pos) <= h60_speed*dt)% check to make sure we don't fly pass the waypoint
        h60_pos = h60_waypoint;
    else
        h60_pos = h60_pos + (h60_waypoint-h60_pos)./norm(h60_waypoint-h60_pos).*h60_speed*dt;
    end

    % RADAR
    % check to make sure pirate is in radar view and dwell time is long enough
    % for track generation

    % EO
    % Generate EO image, take the 50 x 50 from eo_map
    h60_grid = round(h60_pos);
    eo_image = eo_map(h60_grid(2)-25:h60_grid(2)+25, h60_grid(1)-25:h60_grid(1)+25);

    % C2
    p8_waypoint = pirate_pos(1:2);
    h60_waypoint = p8_waypoint;

    % Display scenario
    figure(999);
    imshow(global_map);
    ylim([200 600]);
    hold on,
    plot(pirate_pos(1), pirate_pos(2), 'rs', ...
        p8_pos(1), p8_pos(2), 'bs', ...
        h60_pos(1), h60_pos(2), 'gs');
    plot(search_waypoints(:, 1), search_waypoints(:, 2), 'gs-');
    rect = [p8_pos(1)-100 p8_pos(2)-100, 200, 200];
    rectangle('Position', rect, 'EdgeColor', 'b');
    axis on;
    hold off;

    figure(9);
    imshow(eo_image);
    pause(0.1);
end


%%
test = c2_main(1, 2, 3);