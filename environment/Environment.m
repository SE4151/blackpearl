function[traffic_matrix,traffic_image_matrix,boarded,pirate_pos2]=Environment(time)
% ENVIRONMENT Subsystem that generates map+ships+pirates
% Provide the current simulation time and 
% the return is the environment shipping matrix

% NOTE: This function is designed to operate within a simulation that...
% ...starts at time=0 and progresses. IF you want to run it just once, then...
% ...ensure you run it initially with a time=0

    persistent pirate_pos ship_pos_east ship_pos_west boats_pos tanker_id pirate_boat base_map;

%% 
    % Initialize if time=0
        if time==0 
            boarded=0;

        %initial ship positions
            [ship_pos_east, ship_pos_west,boats_pos]=InitializeShips(40,40);

        %initial pirate position and select target tanker
            [pirate_pos,tanker_id]=InitializePirate(ship_pos_east, ship_pos_west);
        
        % get the pirate picture
            load('pirate_boat.mat'); %The picture of a boat is in variable 'map'
            pirate_boat=map;
            base_map = GenMap;
        end
    %% Generate shipping and pirate environment matrices
    %read and show map
        map=base_map;
  
    %update ship positions with time
        [ship_pos_east_update, ship_pos_west_update,boats_pos_update]=ShipMatrix(time,ship_pos_east,ship_pos_west,boats_pos);

    %update pirate positions with time
        [pirate_pos,xalert,yalert]=PirateMatrix(time,ship_pos_east_update,ship_pos_west_update,pirate_pos,tanker_id);

    %has the pirate boarded?
        [boarded]=PirateBoarded(xalert,yalert);

    %update the shipping map matrix
        [traffic_matrix,traffic_image_matrix]=PlaceShips(ship_pos_east_update, ship_pos_west_update,boats_pos_update,pirate_pos,map,pirate_boat);

        pirate_pos2 = pirate_pos;
end