%%
addpath('../environment/');
addpath('../flight/');
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
c2_output.p8_waypoint = p8_waypoint;
c2_output.h60_waypoint = h60_waypoint;

dt = 100; % time step
for t = 0:dt:10000
    % Generate environment map
    [global_map, eo_map, boarded, pirate_pos] = Environment(t);
    if(boarded == 1)
        figure(999);
        text(220, 230, 'GAME OVER!', 'color', 'r', 'FontSize', 50);
        break;
    end

%    pirate_pos = [0 0];

    % Flight
    % Fly P8
%     if(norm(p8_waypoint-p8_pos) <= p8_speed*dt)% check to make sure we don't fly pass the waypoint
%         p8_pos = p8_waypoint;
%     else
%         p8_pos = p8_pos + (p8_waypoint-p8_pos)./norm(p8_waypoint-p8_pos).*p8_speed*dt;
%     end
%     % Fly H60
%     if(norm(h60_waypoint-h60_pos) <= h60_speed*dt)% check to make sure we don't fly pass the waypoint
%         h60_pos = h60_waypoint;
%     else
%         h60_pos = h60_pos + (h60_waypoint-h60_pos)./norm(h60_waypoint-h60_pos).*h60_speed*dt;
%     end
%     flight_output.p8_position = p8_pos;
%     flight_output.h60_position = h60_pos;
    [flight_output] = flight_main(t, c2_output);
    p8_pos = flight_output.p8_position;
    h60_pos = flight_output.h60_position;

    % RADAR
    % check to make sure pirate is in radar view and dwell time is long enough
    % for track generation
    p8_grid = round(p8_pos);
    origin = [p8_grid(1)-100 p8_grid(2)-100]-1;
    radar_image = global_map(p8_grid(2)-100:p8_grid(2)+100, p8_grid(1)-100:p8_grid(1)+100);
    % Apply threshold
    inx = find(radar_image ~= 255);
    radar_image1 = radar_image;
    radar_image1(inx) = 0;
%     imshow(radar_image1);

    % Image processing
    outline = bwperim(radar_image1, 4);
%     imshow(outline)

    % Calculate segment properties, find detection
    stat = regionprops(outline, 'Centroid', 'Area');
    new_detection = zeros(length(stat), 3);
    for k = 1:length(stat)
        new_detection(k, 1:2) = stat(k).Centroid + origin;
        new_detection(k, 3) = stat(k).Area;
    end

    % NEED TRACKING ALGORITHM HERE!

    % check to see if radar is in view
    test = new_detection(:, 1:2) - repmat(pirate_pos(1:2), size(new_detection, 1), 1);
    test = sqrt(test(:, 1).^2 + test(:, 2).^2); % distance of detection to pirate position
    [test inx] = sort(test);
    if(min(test) < 1) % in view
        detection_age = detection_age + 1;
        if(detection_age > 1)
            detected_pirate_pos = new_detection(inx(1), 1:2);
            detected_pirate_vel = (new_detection(inx(1), 1:2) - last_pirate_pos)/dt;
        end
        last_pirate_pos = new_detection(inx(1), 1:2);
    else % no pirate in view
        detected_pirate_pos = [];
        detected_pirate_vel = [];
        detection_age = 0;
    end
    % Radar output
    radar_output(1).position = detected_pirate_pos;
    radar_output(1).velocity = detected_pirate_vel;

    % EO
    % Generate EO image, take the 50 x 50 from eo_map
    h60_grid = round(h60_pos);
    eo_image = eo_map(h60_grid(2)-25:h60_grid(2)+25, h60_grid(1)-25:h60_grid(1)+25);
    score = corr2(eo_image, pirate_ref);
    if(score > 0.99)
        eo_output.valid_target = 1;
    else
        eo_output.valid_target = 0;
    end

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
    plot(new_detection(:, 1), new_detection(:, 2), 'co'); % Detection
    %legend('Pirate', 'P8', 'H60');
    plot(search_waypoints(:, 1), search_waypoints(:, 2), 'gs-');
    rect = [p8_pos(1)-100 p8_pos(2)-100, 200, 200];
    rectangle('Position', rect, 'EdgeColor', 'b');
    text(20, 580, sprintf('t = %.0f', t), 'color', 'r', 'FontSize', 16, 'BackgroundColor', 'w');
    if(eo_output.valid_target == 1)
        text(220, 230, 'PIRATE INTERCEPTED!', 'color', 'g', 'FontSize', 50);
        break;
    end
    axis off;
    hold off;

    figure(9);
    imshow(eo_image);
    set(gcf, 'Name', 'EO Image');
    pause(0.01);
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