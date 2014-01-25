function [x, y, z] = PlaceBox(placedBoxes, EP, length, width)
% PlaceBox - Chooses at which 
%
% Inputs:
%    placedBoxes - a matrix of boxes already placed
%                  {BoxID, (x,y,z) of left-back-down corner,
%                   width, length, height}
%    EP - an (x,y,z) matrix of current extreme points
%    width - width of the box
%    length - length of the box
%    height - height of the box
%
% Outputs:
%    [x y z] - coordinates of the EP where the left-back-down
%              corner of the box was placed

% Exclude placeholders for future boxes
placedBoxes(placedBoxes(:,1) == 0, :) = [];

% Reduce data array to just min and max x, y, and z coordinates
minmaxXYZCoords = [placedBoxes(:,1) ...
                   placedBoxes(:,2) placedBoxes(:,2)+placedBoxes(:,5) ...
                   placedBoxes(:,3) placedBoxes(:,3)+placedBoxes(:,6) ...
                   placedBoxes(:,4) placedBoxes(:,4)+placedBoxes(:,7)];

% Sort by max z-coord for each present
minmaxXYZSorted = sortrows(minmaxXYZCoords,-7);

% Iterate through each EP
n = size(EP,1);
possibleEP = zeros(n,3);
for k = 1:n
    x = EP(k,1);
    y = EP(k,2);
    z = EP(k,3);    

    if BoxFits(x, y, z)
        possibleEP(k,:) = [x y z];
    end
    % ***********
    % Need to implement residual space
    % ***********
end

% Using the best fit rule
possibleEP(possibleEP(:,1) == 0, :) = [];
possibleEP = sortrows(possibleEP, [3 2 1]);
x = possibleEP(1,1);
y = possibleEP(1,2);
z = possibleEP(1,3);

    function value = BoxFits(x, y, z)
    % BoxFits - Returns true if the box fits as (x,y,z),
    %           i.e. no collisions and inside container
    %
    % Inputs:
    %    width, length, height of the box to be placed
    %    x,y,z - EP where left-back-down corner of box is to be placed
    %
    % Outputs:
    %    value - true if no collisions and inside container
    
    % Verify that box will be inside container
    if or(x + width > 1000, y + width > 1000)
        value = false;
        return
    end
    
    % Check box i for collisions against other placed box
    % Compare present i against other presents, checking for collision
    for j = 1:size(placedBoxes,1)
        % Test for collision on z-axis first, since sorted
        maxZj = minmaxXYZSorted(j,7); 
        if z >= maxZj
            % No overlap on z-axis implies no collision
            break
        end

        % Test for collision on x-axis      
        minXj = minmaxXYZSorted(j,2);
        maxXj = minmaxXYZSorted(j,3); 
        if or(x + width <= minXj, x >= maxXj)
            % No overlap on x-axis implies no collision
            continue
        end

        % Test for collision on y-axis
        minYj = minmaxXYZSorted(j,4); 
        maxYj = minmaxXYZSorted(j,5);
        if or(y + length <= minYj, y >= maxYj)
            % No overlap on y-axis implies no collision
            continue
        end

        % Overlap on x, y, and z axes indicates collision
%         fprintf('Collision check FAILED: packages %d and %d collided\n',1,minmaxXYZSorted(j,1));
        value = false;
        return
    end
    
    value = true;
    end

end


%% Sample code for parfor

%     % Re-implementing BoxFits() inside the loop
%     fits = true;
%     % Verify that box will be inside container
%     if or(x + length > containerLength, y + width > containerWidth)
%         fits = false;
%     else    
%         % Check box i for collisions against other placed box
%         % Compare present i against other presents, checking for collision
%         for o = 1:size(placedBoxes,1)
%             % Test for collision on z-axis first, since sorted
%             maxZj = minmaxXYZSorted(o,7); 
%             if z >= maxZj
%                 % No overlap on z-axis implies no collision
%                 continue;
%             end
% 
%             % Test for collision on x-axis      
%             minXj = minmaxXYZSorted(o,2);
%             maxXj = minmaxXYZSorted(o,3); 
%             if or(x + width <= minXj, x >= maxXj)
%                 % No overlap on x-axis implies no collision
%                 continue
%             end
% 
%             % Test for collision on y-axis
%             minYj = minmaxXYZSorted(o,4); 
%             maxYj = minmaxXYZSorted(o,5);
%             if or(y + length <= minYj, y >= maxYj)
%                 % No overlap on y-axis implies no collision
%                 continue
%             end
% 
%             % Overlap on x, y, and z axes indicates collision
%             fits = false;
%         end
%     end
% 
%     if fits
%         possibleEP(k,:) = [x y z];
%     end