    %% A.1.7.2 Place Ships at ship locations
    % PLACESHIPS places the tankers, boats, and pirate into the environment shipping matrix
    
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
    end