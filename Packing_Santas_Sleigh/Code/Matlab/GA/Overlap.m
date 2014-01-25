function overlap = Overlap(placedBoxes, EP, length, width)
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