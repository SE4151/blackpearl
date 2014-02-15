classdef C2_Output_Interface
% This class defines the output data structure from C2 sub-system.    
    properties
        valid_target = logical(false); % A logic flag declares that a pirate has been observed by h60.
        p8_waypoint = [0 0]; % p8 waypoint in global (x, y) coordinate, unit: pixel
        h60_waypoint = [0 0]; % h60 waypoint in global (x, y) coordinate, unit: pixel
    end
end