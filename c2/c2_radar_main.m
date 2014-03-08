function track_output = c2_radar_main(time, global_map, p8_pos)

% grab image from global map
p8_grid = round(p8_pos);
origin = [p8_grid(1)-100 p8_grid(2)-100]-1;
radar_image = global_map(p8_grid(2)-100:p8_grid(2)+99, p8_grid(1)-100:p8_grid(1)+99);
% Apply threshold
inx = find(radar_image ~= 255);
radar_image1 = radar_image;
radar_image1(inx) = 0;

% Image processing
outline = bwperim(radar_image1, 4);

% Calculate segment properties
stat = regionprops(outline, 'Centroid', 'Area');
new_detection = zeros(length(stat), 3);
for k = 1:length(stat)
    new_detection(k, 1:2) = stat(k).Centroid + origin;
    new_detection(k, 3) = stat(k).Area;
    new_detection(k, 4) = 0; % 0 means not be used with any old track
end

%%
pirate_speed = 1/120; % pixel/sec

%% Associate detection to track id
persistent track_record;
if(time == 0)
    track_record = [];
end
for k = 1:length(track_record)
    dt = (time - track_record(k).last_observation_time);
    % propagate old track to current time
    track_record(k).pos = track_record(k).history(end, 1:2) + track_record(k).vel*dt;
    % calculate distance to all detections
    dist = new_detection(:, 1:2) - repmat(track_record(k).pos, size(new_detection, 1), 1);
    dist = sqrt(dist(:, 1).^2 + dist(:, 2).^2); % distance of detection to track position
    % calculate distance threshold
    factor = 1;
    if(track_record(k).size == 1)% either pirate or neutral
        if(norm(track_record(k).vel) == 0)
            threshold = pirate_speed * dt * sqrt(2) * factor; % off by 1 pixel diagnally * factor
        else
            threshold = norm(track_record(k).vel) * dt * sqrt(2) * factor;
        end
    else
        threshold = neutral_speed * dt * sqrt(2) * factor;
    end
    % how many are within threshold?
    [potential] = find(dist <= threshold);
    if(length(potential) == 0)
        % No detection associated with track, get next track
        continue;
    elseif(length(potential) == 1)
        % choose the only detection
        det_inx = potential;
    else
        % find all the closest size 1 detection
        [size1_inx] = find(new_detection(potential, 3) == 1);
        if(length(size1_inx) ~= 0) % pick the closest one from all size 1 detection
            [min_size1 min_size1_inx] = min(size1_inx);
            det_inx = potential(size1_inx(min_size1_inx));
        else % pick the closest one
            [dummy inx] = min(potential); % index to potential
            det_inx = potential(inx); % index back to new_detection matrix
        end
    end
    % increament detection used counter
    new_detection(det_inx, 4) = new_detection(det_inx, 4) + 1;
    % update track using the new detection
    new_pos = new_detection(det_inx, 1:2);
    old_pos = track_record(k).history(end, 1:2);
    if(norm(new_pos - old_pos) ~= 0) % update velocity only when track has moved
        track_record(k).pos = new_pos;
        track_record(k).history(size(track_record(k).history, 1) + 1, :) = [new_pos time];
        history_size = (size(track_record(k).history, 1));
        if(history_size > 1)
            inx = 1:history_size;
            % Use last 6 history points
            if(history_size > 6)
                inx = (history_size - 6):history_size;
            end
            % Use linear regression to calculate velocity
            px = polyfit(track_record(k).history(inx, 3), track_record(k).history(inx, 1), 1);
            py = polyfit(track_record(k).history(inx, 3), track_record(k).history(inx, 2), 1);
            vel = [px(1) py(1)];
        else
            vel = (new_pos - old_pos)/dt;
        end
        track_record(k).vel = vel;
        % insert new position to history
        track_record(k).last_observation_time = time;
    end
    track_record(k).pos = new_pos;
end

%% Initialize new track
persistent last_track_id;
if(time == 0)
    last_track_id = 0;
end
% remove used detections
unused_inx = find(new_detection(:, 4) == 0); % unused detection
unused_detection = new_detection(unused_inx, :);

% remove detection whose size are great then 1
size1_inx = find(unused_detection(:, 3) == 1); % size 1 detection
detections = unused_detection(size1_inx, :);
% initiate new track
for k = 1:size(detections, 1);
    last_track_id = last_track_id + 1;
    new_track.id = last_track_id;
    new_track.size = detections(k, 3);
    new_track.pos = detections(k, 1:2);
    new_track.vel = [0 0];
    new_track.history = [detections(k, 1:2) time]; % history of positions
    new_track.last_observation_time = time;
    new_track.initiation_time = time; % don't report if age is too small < 2,
    new_track.initial_size = detections(k, 3); % propably don't need this

    % append to track record
    inx = length(track_record) + 1;
    if(inx == 1)
        track_record = new_track;
    else
        track_record(inx) = new_track;
    end
%    disp(sprintf('%.0f, track added', time));
end

%% Debug
% figure(99);
% imshow(global_map)
% ylim([200 600]);
% %axis([new_detection(:, 1)-10 new_detection(:, 1)+10 new_detection(:, 2)-10 new_detection(:, 2)+10]);
% hold on;
% plot(new_detection(:, 1), new_detection(:, 2), 'co');
% for k = 1:length(track_record)
%     plot(track_record(k).history(:, 1), track_record(k).history(:, 2), 'g*');
%     plot(track_record(k).pos(1), track_record(k).pos(2), 'r*');
%     text(track_record(k).pos(1), track_record(k).pos(2), num2str(track_record(k).id));
% end
% hold off;

%% Remove old tracks
age_threshold = 3 * 1/pirate_speed; % 3 pixel time
inx = [];
for k = 1:length(track_record)
    if(time - track_record(k).last_observation_time < age_threshold) % fresh tracks
        inx(length(inx) + 1) = k;
    end
end
if(length(inx) ~= length(track_record))
%    disp(sprintf('%.0f, track removed', time));
end
track_record = track_record(inx);

%% Report current tracks
inx = [];
for k = 1:length(track_record)
    if(norm(track_record(k).vel) > 0) % fresh tracks
        inx(length(inx) + 1) = k;
    end
end
track_output = track_record(inx);


