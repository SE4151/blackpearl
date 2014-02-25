%% A.1.3 Initialize Shipping
% INITIALIZESHIPS establishes the start positions for the tankers and ...
%...fishing boats

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
    end