%% Packing Santa's Sleigh Competition - MATLAB Sample Code
%  
% This sample code will get you started with MATLAB for the Packing Santa's
% Sleigh Competition. You will import data, analyze, and visualize data,
% implement a naive optimization algorithm, evaluate the naive solution
% using the competition metric, and export a submission file.
%
% You can call the sample code from the command line by typing:
% Santas_Sleigh_MATLAB_Sample_Code
%
% The exported submission file will have the name submissionfile.csv.

% Copyright 2013 The MathWorks, Inc.


%% Importing Data
% You can use csvread to import presents.csv and save as a new variable

% First row of data (zero based, skip the header)
firstRow = 1;

% First column of data (zero based, don't skip any columns)
firstCol = 0;

% Store data in a variable called presents
presents = csvread('../../Data/presents.csv', firstRow, firstCol);

% You can also use the Import Data button on the Home tab of the MATLAB
% Toolstrip. This will allow you to import data, as well as auto-generate
% code to perform the exact steps from the Import wizard. Everything done
% manually can be translated to the programmatic equivalent.

%% Analyzing Data
% Once the data is loaded, you may want to understand some basic statistics
% about the dataset.

% Check the size of the presents variable; each row represents the
% dimensions of one present
[rows, columns] = size(presents);
numPresents = rows % the number of presents will be displayed in the Command Window

% Save the columns as separate arrays, representing the IDs, widths,
% lengths, and heights of each present
presentIDs = presents(:,1);
presentWidth = presents(:,2);
presentLength = presents(:,3);
presentHeight = presents(:,4);

% Compute the present volumes and determine the min and max volume; the
% results will be displayed in the Command Window
presentVol = [presentIDs, presentWidth(:).*presentLength(:).*presentHeight(:)];
minVol = min(presentVol(:,2))
maxVol = max(presentVol(:,2))

%% Visualizing Data
% Plotting data is another good way to get a feel for large data sets. You
% can create a 3-D plot that represents the dimensions of each present.

% Create figure, plot, and axis labels
figure1 = figure('Name','Santa''s Presents');
plot3(presentWidth, presentLength, presentHeight, '.')
xlabel('width');
ylabel('length');
zlabel('height');
title('Present Sizes');

%% A Naive Approach
% One possible approach would be to place the boxes in order going from top
% to bottom.  This will have the advantage of having 0 penalty for the
% ordering part of the metric, however the total height will likely not be
% very good.  To do this, we'll start by filling presents along the
% x-direction.  Once there's no more room in the x-direction, we increment
% the y-direction.  Once there's no more room in the y-direction, we
% increment the z-direction. (Note that this approach
% takes 10 seconds or so to execute. Your own solution may take more or
% less time, depending on the complexity and your machine.)

% Parameters
width = 1000;
length = 1000;
xs = 1; ys = 1; zs = -1; % Initial coordinates for placing boxes
lastRowIdxs = zeros(100,1); % Buffer for storing row indices
lastLayerIdxs = zeros(500,1); % Buffer for storing layer indices
numInRow = 0;
numInLayer = 0;
presentCoords = zeros(numPresents,25); % PresentID and 8 sets of coordinates per present

for i = 1:numPresents
    % Move to the next row if there isn't room
    if xs + presentWidth(i) > width + 1 % exceeded allowable width
        ys = ys + max(presentLength(lastRowIdxs(1:numInRow))); % increment y to ensure no overlap
        xs = 1;
        numInRow = 0;
    end
    % Move to the next layer if there isn't room
    if ys + presentLength(i) > length + 1 % exceeded allowable length
        zs = zs - max(presentHeight(lastLayerIdxs(1:numInLayer))); % increment z to ensure no overlap
        xs = 1;
        ys = 1;
        numInLayer = 0;
    end
    
    % Fill present coordinate matrix
    presentCoords(i,1) = presentIDs(i);
    presentCoords(i,[2 8 14 20]) = xs;
    presentCoords(i,[5 11 17 23]) = xs + presentWidth(i) - 1;
    presentCoords(i,[3 6 15 18]) = ys;
    presentCoords(i,[9 12 21 24]) = ys + presentLength(i) - 1;
    presentCoords(i,[4 7 10 13]) = zs;
    presentCoords(i,[16 19 22 25]) = zs - presentHeight(i) + 1;

    % Update location info
    xs = xs + presentWidth(i);
    numInRow = numInRow+1;
    numInLayer = numInLayer+1;
    lastRowIdxs(numInRow) = presentIDs(i);
    lastLayerIdxs(numInLayer) = presentIDs(i);
end

% We started at z = -1 and went downward, need to shift so all z-values >=
% 1
zCoords = presentCoords(:,4:3:end);
minZ = min(zCoords(:));
presentCoords(:,4:3:end) = zCoords - minZ + 1;

%% Computing the Evaluation Metric
% How well Santa's sleigh is packed will be judged by the overall
% compactness of the packing and the ordering of the presents: 
% metric  = 2 * max(z-coordinates) + sigma(order)

% Ideal order is the original order
idealOrder = presentIDs; 

% Determine the max z-coordinate; this is the max height of the sleigh
maxZ = max(max(presentCoords(:,4:3:end)));

% Go down the layers from top to bottom, reorder presents in numeric order
% for each layer
maxZCoord = zeros(numPresents,2);
for i = 1:numPresents
    maxZCoord(i,1) = presentCoords(i);
    maxZCoord(i,2) = max(presentCoords(i,4:3:end));
end
maxzCoordSorted = sortrows(maxZCoord,[-2 1]); %sort max z-coord for each present
reOrder = maxzCoordSorted(:,1);

% Compare the new order to the ideal order
order = sum(abs(idealOrder - reOrder));

% Compute metric
metric = 2*maxZ + order;

%% Creating a Submission File
% You can use fprintf to write the header, present IDs, and coordinates to
% a CSV file. (Note that this step may take a minute or so to execute,
% depending on your machine.)
subfile = strrep(strcat('../../Submissions/', num2str(metric), ' - SampleCode (', datestr(now), ').csv'), ':', '.');
fileID = fopen(subfile, 'w');Bin 
headers = {'PresentId','x1','y1','z1','x2','y2','z2','x3','y3','z3','x4','y4','z4','x5','y5','z5','x6','y6','z6','x7','y7','z7','x8','y8','z8'};
fprintf(fileID,'%s,',headers{1,1:end-1});
fprintf(fileID,'%s\n',headers{1,end});
fprintf(fileID,'%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n',presentCoords');
fclose(fileID);