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
search_waypoints = [297 628; 405 323 ];
search_waypoints = search_waypoints';
p8_pos = launch_pos;
h60_pos = launch_pos;
p8_waypoint = search_waypoints(1, :);
h60_waypoint = p8_waypoint;


dt = 100; % time step
for t = 0:dt:10000
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
    flight_output.p8_position = p8_pos;
    flight_output.h60_position = h60_pos;

    % RADAR
    % check to make sure pirate is in radar view and dwell time is long enough
    % for track generation
    if((pirate_pos(1) >= p8_pos(1)-100 & pirate_pos(1) <= p8_pos(1)+100) & ...
        (pirate_pos(2) >= p8_pos(2)-100 & pirate_pos(2) <= p8_pos(2)+100))
        % pirate in radar field of view

    else

    end
    if(t == 0)
        last_pirate_pos = pirate_pos(1:2);
    end
    radar_output(1).position = pirate_pos(1:2);
    radar_output(1).velocity = (pirate_pos(1:2) - last_pirate_pos)/dt;
    last_pirate_pos = pirate_pos(1:2);

    % EO
    % Generate EO image, take the 50 x 50 from eo_map
    h60_grid = round(h60_pos);
    eo_image = eo_map(h60_grid(2)-25:h60_grid(2)+25, h60_grid(1)-25:h60_grid(1)+25);
    eo_output.valid_target = 0;

    % C2
%    p8_waypoint = pirate_pos(1:2);
%    h60_waypoint = p8_waypoint;
    c2_output = c2_main(t, dt, radar_output, eo_output, flight_output);
    p8_waypoint = c2_output.p8_waypoint;
    h60_waypoint = c2_output.h60_waypoint;

    % Display scenario
    figure(999);
    imshow(global_map);
    ylim([200 600]);
    hold on,
    plot(pirate_pos(1), pirate_pos(2), 'rs', ...
        p8_pos(1), p8_pos(2), 'bs', ...
        h60_pos(1), h60_pos(2), 'go');
    %legend('Pirate', 'P8', 'H60');
    plot(search_waypoints(:, 1), search_waypoints(:, 2), 'gs-');
    rect = [p8_pos(1)-100 p8_pos(2)-100, 200, 200];
    rectangle('Position', rect, 'EdgeColor', 'b');
    text(20, 580, sprintf('t = %.0f', t), 'color', 'r', 'FontSize', 16, 'BackgroundColor', 'w');
    axis off;
    hold off;

    figure(9);
    imshow(eo_image);
    set(gcf, 'Name', 'EO Image');
%    pause(0.1);
end


%%
map = imread('africa_map.png');

search_waypoints = [297 628 646 582 464; ...
                    405 323 524 675 840];
search_waypoints = search_waypoints';

figure(1);
imshow(map);
colormap('gray')

hold on;
plot(search_waypoints(:, 1), search_waypoints(:, 2), 'gs-');
hold off;


axis image;
hold on;
id = 1;
rect = [search_waypoints(id, 1)-100 search_waypoints(id, 2)-100, 200, 200];
rectangle('Position', rect, 'EdgeColor', 'r');
hold off;

%%
figure(2);
mask2 = im2bw(mask, graythresh(mask));
bwtraceboundary(mask2, [681 337], 'N', 4);
bound = bwboundaries(mask);
bound = cell2mat(bound);
plot(bound(:, 1), bound(:, 2));
%%



%%
test = c2_main(1, 2, 3);