%% Set parameters and initialize variables

% Container parameters
containerWidth = 1000; % x-axis of container
containerLength = 1000; % y-axis of container
containerHeight = intmax; % z-axis of container (set to a pre-computed near-optimal value)

% Sorting parameters
orthogonalRotations = true; % are orthogonal rotations allowed?
online = false; % should we sort the boxes?
sortType = 'Area-Height'; % valid values are 'Area-Height' and 'Height-Area'
delta = 5; % [1, 100] used to initially sort the boxes

% Initialize algorithm variables
if matlabpool('size') ~= 0
    matlabpool close;
end
% matlabpool open;
tic;

%% Import/create the data
boxes = csvread('../../../Data/presents.csv', 1, 0); % BoxID, width, length, height
boxes = int32(boxes); % convert to ints
% boxes = boxes(1:1000,:); % for testing
n = size(boxes, 1);

% Add orthogonally rotated copies of each box
% We will add all permutations to the bottom of the matrix
% and delete the original entries afterwards
if orthogonalRotations
    % Re-size the boxes matrix once by sextupling
    boxes = [boxes; zeros(6*n, 4)];
    index = n+1;
    for i = 1:n
        id = boxes(i,1);
        uniquePermutations = unique(perms(boxes(i, 2:4)), 'rows');
        a = size(uniquePermutations, 1);
        boxes(index:index+a-1, :) = [repmat(id, a, 1), uniquePermutations];
        index = index + a;
    end
    % Delete original entries and leftover space at bottom
    boxes(1:n,:) = [];
    boxes(boxes(:,1) == 0, :) = [];
end

% Should the box matrix be sorted?
if online
    boxes = SortByCluster(boxes, sortType, delta, containerWidth, containerLength, containerHeight);
end

%% Execute algorithm
pendingBoxes = boxes;
EP = [];

% BoxID, (x,y,z) of left-back-down corner, width, length, height
placedBoxes = zeros(n, 7);

h = waitbar(0,'Initializing waitbar...');
for i = 1:n
    % Track progress
    waitbar(i/n,h,sprintf('%d%% along...',floor(i/n*100)))
    
    id = pendingBoxes(1, 1);
    width = pendingBoxes(1, 2);
    length = pendingBoxes(1, 3);
    height = pendingBoxes(1, 4);
    
    % If this is the first box, place it at the origin
    if all(all(placedBoxes'==0))
        x = 0;
        y = 0;
        z = 0;
        EP = [width 0 0; 0 length 0; 0 0 height];
    else
        % Place new box
        [x, y, z] = PlaceBox(placedBoxes, EP, width, length);
        
        % Update EP's
        EP = UpdateEP(placedBoxes, EP, x, y, z, width, length, height);
    end

    % Add new box to list of boxes placed
    placedBoxes(i, :) = [id x y z pendingBoxes(1, 2:4)];
    
    % Delete original box and all rotations from pendingBoxes
    pendingBoxes(pendingBoxes(:,1) == id, :) = [];
end
close(h)

%% Computing the Evaluation Metric
% Transform placedBoxes into submission format
placedBoxes;
ID = placedBoxes(:,1);
x = placedBoxes(:,2);
y = placedBoxes(:,3);
z = placedBoxes(:,4);
width = placedBoxes(:,5);
length = placedBoxes(:,6);
height = placedBoxes(:,7);
presentCoords = [ID ...
                 x y z ...
                 x y+length z ...
                 x y z+height ...
                 x y+length z+height ...
                 x+width y z ...
                 x+width y+length z ...
                 x+width y z+height ...
                 x+width y+length z+height];

% Ideal order is the original order
idealOrder = ID; 

% Determine the max z-coordinate; this is the max height of the sleigh
maxZ = max(max(presentCoords(:,4:3:end)));

% Go down the layers from top to bottom, reorder presents in numeric order
% for each layer
maxZCoord = zeros(n,2);
for i = 1:n
    maxZCoord(i,1) = presentCoords(i);
    maxZCoord(i,2) = max(presentCoords(i,4:3:end));
end
maxzCoordSorted = sortrows(maxZCoord,[-2 1]); %sort max z-coord for each present
reOrder = maxzCoordSorted(:,1);

% Compare the new order to the ideal order
order = sum(abs(idealOrder - reOrder));

% Compute metric
metric = 2*maxZ + order;

%% Output Solution
subfile = strrep(strcat('../../../Submissions/', num2str(metric), ' - C-EPBFD (', datestr(now), ').csv'), ':', '.');
fileID = fopen(subfile, 'w');
headers = {'PresentId','x1','y1','z1','x2','y2','z2','x3','y3','z3','x4','y4','z4','x5','y5','z5','x6','y6','z6','x7','y7','z7','x8','y8','z8'};
fprintf(fileID,'%s,',headers{1,1:end-1});
fprintf(fileID,'%s\n',headers{1,end});
fprintf(fileID,'%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n',presentCoords');
fclose(fileID);

% matlabpool close;
toc