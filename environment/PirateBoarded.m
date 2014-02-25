%% A.1.8 Detect Pirate Boarded
% PIRATEBOARDED is simple detector of whether or not the pirate position...
% and target tanker positions match

    function[boarded]=PirateBoarded(xalert,yalert)
        boarded=0;
    % the pirate has boarded if the xalert and yalert are both 1
        if (xalert+yalert==2)
            boarded=1;
        end
        
    end