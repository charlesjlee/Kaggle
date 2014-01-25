function UpdatedEP = UpdateEP(placedBoxes, EP, x, y, z, width, length, height)
% UpdateEP - Updates the list of EP points after placing the new box
%
% Inputs:
%    placedBoxes - a matrix of boxes already placed
%                  {BoxID, (x,y,z) of left-back-down corner,
%                   width, length, height}
%    EP - an (x,y,z) matrix of current extreme points
%    x - x-coordinate of the left-back-down corner
%    y - y-coordinate of the left-back-down corner
%    z - z-coordinate of the left-back-down corner
%    width - width of the box
%    legnth - legnth of the box
%    height - height of the box
%
% Outputs:
%    UpdatedEP - an updated matrix of extreme points

% Delete EP at (x,y,z)
EP(ismember(EP,[x y z],'rows'),:) = [];

% Exclude placeholders for future boxes
placedBoxes(placedBoxes(:,1) == 0, :) = [];

% Test each of the 6 EP's generated
maxBound = repmat(-1, 1, 6);
newEP = zeros(6,3);

for i = 1:size(placedBoxes,1)
    x_i = placedBoxes(i,2);
    y_i = placedBoxes(i,3);
    z_i = placedBoxes(i,4);
    width_i = placedBoxes(i,5);
    length_i = placedBoxes(i,6);
    height_i = placedBoxes(i,7);
    if CanTakeProjection(1) && (x_i + width_i > maxBound(1))
        newEP(1,:) = [x_i + width_i, y + length, z];
        maxBound(1) = x_i + width_i;
    end
    if CanTakeProjection(2) && (z_i + height_i > maxBound(2))
        newEP(2,:) = [x, y + length, z_i + height_i];
        maxBound(2) = z_i + height_i;
    end
    if CanTakeProjection(3) && (y_i + length_i > maxBound(3))
        newEP(3,:) = [x + width, y_i + length_i, z];
        maxBound(3) = y_i + length_i;
    end
    if CanTakeProjection(4) && (z_i + height_i > maxBound(4))
        newEP(4,:) = [x + width, y, z_i + height_i];
        maxBound(4) = z_i + height_i;
    end
    if CanTakeProjection(5) && (x_i + width_i > maxBound(5))
        newEP(5,:) = [x_i + width_i, y, z + height];
        maxBound(5) = x_i + width_i;
    end
    if CanTakeProjection(6) && (y_i + length_i > maxBound(6))
        newEP(6,:) = [x, y_i + length_i, z + height];
        maxBound(6) = y_i + length_i;
    end
end

% Delete unused rows from pre-allocated zeros matrix
newEP(newEP(:,1) == 0, :) = [];

% Update the EP matrix
UpdatedEP = union(EP, newEP, 'rows');
UpdatedEP = sortrows(UpdatedEP, [3 2 1]);

    function value = CanTakeProjection(axis)
    % CanTakeProjection - Updates the list of EP points after placing the new box
    %
    % Inputs:
    %    k - the box being placed
    %    i - a box that has already been placed
    %    axis -  ???
    %
    % Outputs:
    %    value - true if an extreme point lies on the side of item k
    value = true;
    end
    
end