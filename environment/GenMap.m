%% A.1.1 Generage Map Baseline (Read Map, Store Map)
%GENMAP loads map file for use by the Enviroment subsystem

    function[map]=GenMap()
    
    % Open the image file and store the image in the variable 'map'
    %(UPDATE file name (if not in the same directory) when integrated!)
        load ('horn_gray.mat'); 
        
    end