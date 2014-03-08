function[traffic_matrix,traffic_image_matrix,boarded,current_pirate_pos]=Environment(time)
% ENVIRONMENT Subsystem that generates map+ships+pirates
% Provide the current simulation time and 
% the return is the environment shipping matrix

% NOTE: This function is designed to operate within a simulation that...
% ...starts at time=0 and progresses. IF you want to run it just once, then...
% ...ensure you run it initially with a time=0

    persistent pirate_pos ship_pos_east ship_pos_west boats_pos tanker_id pirate_boat

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
			%imshow(pirate_boat);
			pause(1);
        end
    %% Generate shipping and pirate environment matrices
    %read and show map
        map=GenMap;
  
    %update ship positions with time
        [ship_pos_east_update, ship_pos_west_update,boats_pos_update]=ShipMatrix(time,ship_pos_east,ship_pos_west,boats_pos);

    %update pirate positions with time
        [pirate_pos,xalert,yalert]=PirateMatrix(time,ship_pos_east_update,ship_pos_west_update,pirate_pos,tanker_id);
        current_pirate_pos=pirate_pos(1,1:2);

    %has the pirate boarded?
        [boarded]=PirateBoarded(xalert,yalert);

    %update the shipping map matrix
        [traffic_matrix,traffic_image_matrix]=PlaceShips(ship_pos_east_update, ship_pos_west_update,boats_pos_update,pirate_pos,map,pirate_boat);
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% A.1.3 Initialize Shipping
% INITIALIZESHIPS establishes the start positions for the tankers and ...
%...fishing boats
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[ship_pos_east,ship_pos_west,boats_pos]=InitializeShips(num_ships,num_boats)
    % the number of tankers = num_ships
    % the number of boats = num_boats
    % initialize a ship position matrix "ship_pos"
        ship_pos_east=zeros(num_ships/2,2);
        ship_pos_west=zeros(num_ships/2,2);
        boats_pos=zeros(num_boats,2);
    % generate random starting positions for each ship in the Gulf of Aden
    
    % east-bound ships
        for i=1:num_ships/2
            x=round(498*rand+237);% east/west start
            ship_pos_east(i,1)=x; %east bound matrix       
            ship_pos_east(i,2)=round(-.167*x+455); %east channel eq.
        end
            ship_pos_east=sortrows(ship_pos_east);
            
    % west-bound ships
        for i=1:num_ships/2
            x=round(391*rand+253);% east/west start
            ship_pos_west(i,1)=x; %west bound matrix
            ship_pos_west(i,2)=round(-.386*x+515); %west channel eq.
        end
            ship_pos_west=sortrows(ship_pos_west);
    % fishing boat positions
        for i=1:num_boats
                x=round(498*rand+237);% east/west start
                boats_pos(i,1)=x;
                boats_pos(i,2)=round(-.2*x+475+50*(2*(rand-.5)));
	end
end %InitializeShips(num_ships,num_boats)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% A.1.5 Initialize Pirate
% INITIALIZEPIRATE randomly selects a pirate launch location
% and then selects target tanker
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[pirate_pos,tanker]=InitializePirate(east,west)
    % Initialize pirate position matrix
        pirate_pos=zeros(1,3);
    
    % Candidate launch positions
        launch=[325,450;403,435;456,420;499,421;553,398];
        
    %randomize the selection of the above positions
        i=round(4*rand)+1;
        
    %select start from launch matrix using random number
        pirate_pos(1,1)=launch(i,1);
        pirate_pos(1,2)=launch(i,2);
    % initialize increment counter (used in PirateMatrix)
        pirate_pos(1,3)=0;
        
    %select target tanker
    %combine east and west tankers
        alltankers=vertcat(east,west);
        
    %how many tankers are there (store in 'r')
        [r,c]=size(alltankers);
        
    %pick a tanker near the center of GOA (about the middle of list of ...
    %...all tankers)
       % tanker=round(r*(2*rand-.5)/6+r/2);
       %tanker=35;
       tanker=5;
        
end	%InitializePirate(east,west)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% A.1.1 Generage Map Baseline (Read Map, Store Map)
%GENMAP loads map file for use by the Enviroment subsystem
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[map]=GenMap()
    % Open the image file and store the image in the variable 'map'
    %(UPDATE file name (if not in the same directory) when integrated!)
	load ('horn_gray.mat'); 
        
end% GenMap()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% A.1.4 Generate / Update Ship Matrix
% Gulf of Aden traffic will travel along separate east and west paths on the map
% and tankers will advance 1 pixel every 240 seconds
% and fishing boats advance 1 pixel every 360 seconds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[ships_east,ships_west, boats_out]=ShipMatrix(time,east,west,boats)
    %SHIPMATRIX updates ship positions in a matrix
    % 
    % convert real time into "movement time" for ships and nuetrals
    ship_time=round(time/240);
    boat_time=round(time/360);
    
    %increment east-bound ships
    [r,c]=size(east);
    for i=1:r
        x=ship_time+east(i,1);
        y=round(-.167*x+455); 
        ships_east (i,1)=x;
        ships_east (i,2)=y;
    end
    
    %increment west-bound ships
    [r,c]=size(west);
    for i=1:r
        x=-ship_time+west(i,1);
        y=round(-.386*x+515); 
        if x>230
            ships_west (i,1)=x;
            ships_west (i,2)=y;
        elseif x<=230
            ships_west (i,1)=1;
            ships_west (i,2)=1;
        end
    end

    %increment fishing boats
    [r,c]=size(boats);
    for i=1:r
        x=boat_time+boats(i,1);
        y=boats(i,2);
        %y=round(-.386*x+515);
        boats_out (i,1)=x;
        boats_out (i,2)=y;
    end

end %ShipMatrix(time,east,west,boats)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% A.1.6 Generate / Update Pirate Matrix
% PIRATEMATRIX chases a tanker and updates the position of pirate.  
% It sets the flags 'xalert' and 'yalert' when the pirate x and y positions 
% match the tanker position (i.e., the pirate catches up to the tanker)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[pirate_pos,xalert,yalert]=PirateMatrix(time,east,west,pirate_pos,tanker_id)
    %% 
    % convert real time into "movement time" for pirate
        p_time=round((time-59.9)/120);
        increment=p_time-pirate_pos(1,3);
        xalert=0;yalert=0;

    % combine east and west tankers
        alltankers=vertcat(east,west);

    % current position of target tanker
        target(1,1)=alltankers(tanker_id,1);
        target(1,2)=alltankers(tanker_id,2);

    % compare current pirate and tanker positions

        x(1)=target(1,1)-pirate_pos(1,1);
        x(2)=target(1,2)-pirate_pos(1,2);
    %% 
    % adjust pirate east/west
        if x(1)>0
            pirate_pos(1,1)=pirate_pos(1,1)+increment;
            xalert=0;

        elseif x(1)<0
            pirate_pos(1,1)=pirate_pos(1,1)-increment;
            xalert=0;
            
        else
            xalert=1;

        end

    % adjust pirate north/south
        if x(2)>0
            pirate_pos(1,2)=pirate_pos(1,2)+increment;
            yalert=0;

        elseif x(2)<0
            pirate_pos(1,2)=pirate_pos(1,2)-increment;
            yalert=0;

        else
            yalert=1;

        end

    % store how many times the pirate has moved
        pirate_pos(1,3)=p_time;
end %PirateMatrix(time,east,west,pirate_pos,tanker_id)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% A.1.8 Detect Pirate Boarded
% PIRATEBOARDED is simple detector of whether or not the pirate position...
% and target tanker positions match
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[boarded]=PirateBoarded(xalert,yalert)
	boarded=0;
	% the pirate has boarded if the xalert and yalert are both 1
	if (xalert+yalert==2)
		boarded=1;
	end
end %PirateBoarded(xalert,yalert)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% A.1.7.2 Place Ships at ship locations
% PLACESHIPS places the tankers, boats, and pirate into the environment shipping matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[ship_map,image_map]=PlaceShips(east,west,boats,pirate,map,pix)
    %% For the main shipping matrix:
    
    % Place east-bound tankers (2x2 pixels)
        [r,c]=size(east);
        for i=1:r
            x=east(i,1);
            y=east(i,2);
            map(y:y+1,x:x+1)=255;
        end
    
    % Place east-bound tankers (2x2 pixels)
        [r,c]=size(west);
        for i=1:r
            x=west(i,1);
            y=west(i,2);
            map(y:y+1,x:x+1)=255;    
        end
    
    % Place fishing boats (1 pixel)
        [r,c]=size(west);
        for i=1:r
            x=boats(i,1);
            y=boats(i,2);
            map(y,x)=255;    
        end
    
    % Place pirate ship (1 pixel)
        x=pirate(1,1);
        y=pirate(1,2);
        map(y,x)=255;
        
    % Return the integrated shipping map
        ship_map=map;
        
    %% For the image matrix:
    
    % Find where to center the pix (it is a 51x51 image)
        pix_center_x=x-25; %x is the pirate position x from above
        pix_center_y=y-25; %y is the priate position y from above
    
    % Put the pix on the existing shipping matrix
        map(pix_center_y:pix_center_y+50,pix_center_x:pix_center_x+50)=pix;
    
    % Return the image_matrix with the pirate picture
        image_map=map;
end %PlaceShips(east,west,boats,pirate,map,pix)