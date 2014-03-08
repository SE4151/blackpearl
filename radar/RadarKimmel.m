function [ Pirates] = Radar( Time, postion, map )

%RADAR Function - this function is used to call and control radar system
%The 4.0 Radr Function takes the inputs of time, aircraft positon and the
%traffic matrix and outputs the shiptrack_matrix file which has speed and
%location of pirate vessels
% NOTE: This function is designed to operate within a simulation that...
% ...starts at time=0 and progresses. IF you want to run it just once, then...
% ...ensure you run it initially with a time=0
%  

	aircraftx = round(postion(1));
	aircrafty = round(postion(2));

	Pirates=Radar_Output_Interface;
	persistent Array1 Array2 Array3 Pirates2 Pirates3

	% set radar boundaries
	var xposmax; var xposmin;
	var yposmax; var yposmin;
	var o; var p; var happy;
	ShipvalMatrix = zeros(200,200);
	
	xposmin=(aircraftx-101); xposmax=(aircraftx+100);
	yposmin=(aircrafty-101); yposmax=(aircrafty+100);
	
	scanvol =map(xposmin:xposmax,yposmin:yposmax);
	
	%Detect Targets
 	ModTime = mod(Time,360);
	if (ModTime == 0)
		%reset all Arrays the old data is useless
		Array1= [];
		Array2= [];
		Array3= [];
	end
	%loop through array
	
	%shipval = 2 is a freighter
	%shipval = 1 is a ppirate
	for p = xposmin:1:xposmax
		for o =yposmin:1:yposmax;
			Shipval=0;
			if (map(o,p)== 255); 
				ppirate=[o,p];
				if (map(o+1,p) == 255)
					Shipval=2; %TANKER
					elseif (map(o-1,p) ==255)
					Shipval=2; %TANKER
					elseif (map(o,p+1) == 255)
					Shipval=2; %TANKER
					elseif (map(o+1,p+1) == 255)
					Shipval=2; %TANKER
					elseif (map(o+1,p-1) == 255)
					Shipval=2; %TANKER
					elseif (map(o-1,p+1) == 255)
					Shipval=2;  %TANKER
					elseif (map(o-1,p-1) == 255)
					Shipval=2; %TANKER
				else
					Shipval=1; %SMALL BOAT that I need to add to the tracking matrix
					%need to create at least two matrices one from time 0-110, the other for 120-230, 240-350. Recycle at 360 = 0
					if (ModTime <120)
						%Build Array1
						Array1 = BuildSmallBoatArray(Array1,p,o);
					elseif(ModTime <240)		
						%Build Array2
						Array2 = BuildSmallBoatArray(Array2,p,o);
						pirates3=[];
					elseif(ModTime <360)
						%if(ModTime == 240)
						%	Array1 = cat(Array1, Array2);
						%end
						%Build Array3
						Array3 = BuildSmallBoatArray(Array3,p,o);
						pirates2=[];
					end %ModTime if
				end % Is this a TANKER
			end % if ship
		end % p loop
	end % o loop
	
	% This will be where we pick out the pirates
	ModTime = mod(Time,360);
	if ((110 < ModTime) & (ModTime <230))
		Pirates = SearchArrayForPirates(Array1, Array2, Pirates2); %This should be the output
		elseif (230 < ModTime)
		Pirates = SearchArrayForPirates(Array1, Array3, Pirates3); %This should be the output
	end
	%Return Pirates
end    


function Array = BuildSmallBoatArray(Array, x,y)
	%Is this track already in the Array?
	found = 0;
	for index = 1:2:(length(Array)-1)
		if ((Array(index) == x) & (Array(index+1) == y)); % add this position to the Array
			found = 1;
		end 
	end
	% if this track is not in the Array, add it
	if not(logical(found))
		Array(length(Array) + 1) = x;
        Array(length(Array)+1) = y;
	end
end
			

function possiblePirates = SearchArrayForPirates(First, Second, possiblePirates)
	possiblePirates = Radar_Output_Interface;
	for j = 1:2:length(Second)
		match = logical(0);
		for k = 1:2:(length(First)-1) 
			if (not(match))
				if ((First(k) == Second(j)) & (First(k+1) == Second(j+1)))
					match = logical(1);
					%disp('found a vessel match');
				end
            %else
             %   disp('no match');
            end
		end
		if not(match) %If we didn't find the position call him a possible pirate. 
			if (isempty(possiblePirates(1).position))
                possiblePirates(1).position= [ Second(j) Second(j+1)];
            else
                possiblePirates(length(possiblePirates)+1).position= [ Second(j) Second(j+1)];
            end
		end
	end

end