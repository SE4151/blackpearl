%% A.1.4 Generate / Update Ship Matrix
    % Gulf of Aden traffic will travel along separate east and west paths on the map
    % and tankers will advance 1 pixel every 240 seconds
    % and fishing boats advance 1 pixel every 360 seconds
    
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

    end