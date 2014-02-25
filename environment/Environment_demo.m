function[traffic_matrix,boarded]=Environment_demo(max_time,step_time)
    %ENVIRONMENT_DEMO is a test stub to qualify ENV during development and prior to delivery
    % Use the command "Environment(50000,60);" to demo
    
    %%
    % run a test loop
        for time=0:step_time:max_time
            [traffic_matrix,traffic_image_matrix,boarded]=Environment(time);
            
           %end loop if the pirate has boarded
               if boarded==1 
                   break
               end
               
           % show the map for validation
            refresh(figure(1));

            imshow(traffic_matrix(200:500,100:800)); %only show a portion of the map to save time
            %imshow(traffic_image_matrix(200:500,100:800)); %only show a portion of the map to save time

        end
end