function sortedBoxes = SortByCluster(boxes, type, delta, width, length, height)

% SortByCluster - Reorders the boxes based on the specified cluster type
%                 and delta value
%
% Inputs:
%    boxes - a matrix of boxes. Data headers are:
%            {BoxID, width, length, height}
%    type - the type of clustered sort to apply
%           valid values are 'Area-Height' or 'Height-Area'
%    delta - a float in [1,100] that controls the cluster size
%    width - width of the container
%    length - length of the container
%    height - height of the container
%
% Outputs:
%    sortedBoxes - a matrix of sorted boxes

% Our approach is to create auxiliary columns to sort by
% and drop these columns in the final output
if strcmp(type, 'Area-Height') == 1
    clusterWidth = width * length * delta / 100;
    % Create a new column for the clustering
    boxes(:,5) = ceil(boxes(:,2) .* boxes(:,3) / clusterWidth);
    boxes = sortrows(boxes, [-5 -4]);
    sortedBoxes = boxes(:,1:4);
elseif strcmp(type, 'Height-Area') == 1
    clusterWidth = height * delta / 100;
    % Create a new column for the clustering
    boxes(:,5) = ceil(boxes(:,4) / clusterWidth);
    % Create a new column for the secondary sorting criteria
    boxes(:,6) = boxes(:,2) .* boxes(:,3);
    boxes = sortrows(boxes, [-5 -6]);
    sortedBoxes = boxes(:,1:4);
else
    exception = MException('VerifyOutput:OutOfBounds', ...
                           strcat('Invalid value of \n', type, '\nwas passed for [type] to SortByCluster()'));
    throw(exception);
end