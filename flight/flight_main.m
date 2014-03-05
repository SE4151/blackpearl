function[flight_output]=flight_main(time, c2_output)
%FLIGHT is a subsystem that controls the movement of the HH-60 and the P-8
%aircraft in the SE4151 integration project.

%Expected Inputs:
%From LSI:
%LSI_output.time - simulation time
%LSI_output.dt - change in simulation time since last call/cycle
%
%From C2:
%c2_output.h60_waypoint - should be a 2 element vector (x,y)
%c2_output.p8_waypoint - should be a 2 element vector (x,y)


%Parameters

P8_vel = 1/10; %P8 velocity is 1 pixel per 10 seconds
HH60_vel = 1/30; %HH60 velocity is 1 pixel per 30 seconds
P8_start_pos = [577 406]; %made up starting pos, same as C2 is using for debugging
HH60_start_pos = [577 406]; %made up starting pos
P8_waypoint = c2_output.p8_waypoint;
HH60_waypoint = c2_output.h60_waypoint;
current_time = time;



persistent prev_time HH60_pos P8_pos;

if(time == 0) %place the aircraft at the starting position if time is less than the first time we should move(smallest velocity).
    HH60_pos = HH60_start_pos;
    P8_pos = P8_start_pos;
    prev_time = 0;
    flight_output.p8_position = P8_pos;
    flight_output.h60_position = HH60_pos;
    return;
end

%code to calculate delta_time as the difference from the last call and this
%call, then saves the current time in the previous time, for the next calc

delta_time = current_time - prev_time;
prev_time = current_time;

%Code below should move the P-8 Aircraft

if(norm(P8_waypoint-P8_pos) <= P8_vel*delta_time)%if the distance from us to the waypoint is greater than the movement available for this time period, go to the waypoint and no further
    P8_pos = P8_waypoint;
else
    P8_pos = P8_pos + (P8_waypoint-P8_pos)./norm(P8_waypoint-P8_pos).*P8_vel*delta_time; %Basically, the new position is the old position plus the normalized vector multiplied by the velocity multiplied by time(magnitude)...
end

%Code below should move the HH-60 Aircraft

if(norm(HH60_waypoint-HH60_pos) <= HH60_vel*delta_time)
    HH60_pos = HH60_waypoint;
else
    HH60_pos = HH60_pos + (HH60_waypoint-HH60_pos)./norm(HH60_waypoint-HH60_pos).*HH60_vel*delta_time;
end

%Create the outputs with the new positions

flight_output.p8_position = P8_pos;
flight_output.h60_position = HH60_pos;
    