%% A.1.6 Generate / Update Pirate Matrix
% PIRATEMATRIX chases a tanker and updates the position of pirate.  
% It sets the flags 'xalert' and 'yalert' when the pirate x and y positions 
% match the tanker position (i.e., the pirate catches up to the tanker)

    function[pirate_pos,xalert,yalert]=PirateMatrix(time,east,west,pirate_pos,tanker_id)
    %% 
    % convert real time into "movement time" for pirate
        p_time=round(time/120);
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

    end