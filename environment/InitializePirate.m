%% A.1.5 Initialize Pirate
% INITIALIZEPIRATE randomly selects a pirate launch location
% and then selects target tanker

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
        
    end