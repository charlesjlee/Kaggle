function MATLAB_Metric_v2(presents, submission)
%% Packing Santa's Sleigh Competition - MATLAB Evaluation Metric Calculation
% This function takes as inputs a presents filename and submission file
% filename. During execution, the function returns feedback about whether
% the submission file violates any constraints. If all tests pass, the
% evaluation metric is computed.
%
% You can call the function from a script or from the command
% line using the following syntax:
% Santas_Sleigh_MATLAB_Metric_Calculation('presents.csv', 'submissionfile.csv')

% Copyright 2013 The MathWorks, Inc.

%% Importing Data
% Import original presents data and data from your submission file

presentsfile = presents;
submissionfile = submission;

% First row of data (zero based, skip the header)
firstRow = 1;

% First column of data (zero based, don't skip any columns)
firstCol = 0;

% Store data in a variable called presents
input = csvread(presentsfile, firstRow, firstCol);
submit = csvread(submissionfile, firstRow, firstCol);

[rows, columns] = size(input);
numPresentsInput = rows;

[rows, columns] = size(submit);
numPresentsSubmit = rows;

sleighWidth = 1000;
sleighLength = 1000;

%% Checking Submission Data
% Check to see if your submission file violates any constraints

% Number of presents in should equal number of presents in submission
if (numPresentsInput == numPresentsSubmit)  
    fprintf('Number of presents check PASSED: %d out of %d in submission file\n',numPresentsSubmit,numPresentsInput);
else
    fprintf('Number of presents check FAILED: %d out of %d in submission file\n', numPresentsSubmit,numPresentsInput);
    return
end

% Present dimensions in submission file must match original (input file)
% dimensions
submitDim = zeros(numPresentsSubmit,4);
inputDim = input;
for i = 1:numPresentsSubmit
    submitDim(i,1) = submit(i,1);
    submitDim(i,2) = max(submit(i,2:3:end)) - min(submit(i,2:3:end)) + 1;
    submitDim(i,3) = max(submit(i,3:3:end)) - min(submit(i,3:3:end)) + 1;
    submitDim(i,4) = max(submit(i,4:3:end)) - min(submit(i,4:3:end)) + 1;
    submitDim(i,2:4) = sort(submitDim(i,2:4));
    inputDim(i,2:4) = sort(input(i,2:4));
end

submitDim = sortrows(submitDim,1); % sort submission data by present ID
inputDim = sortrows(inputDim,1); % sort input by present ID

if (submitDim - inputDim) == 0
    fprintf('Dimensions check PASSED: Input and submission dimensions match\n');
else % dimensions don't match
    fprintf('Dimensions check FAILED: Input and submission dimensions don''t match\n');
    return
end

% Packages shouldn't exceed the limitations of the sleigh
if and((max(max(submit(:,2:3:end))) <= sleighWidth),(max(max(submit(:,3:3:end))) <= sleighLength))
    fprintf('Packages fit within sleigh check PASSED: No packages out of sleigh\n')
else
    fprintf('Packages fit within sleigh check FAILED: Packages out of sleigh\n')
    return
end

% Packages can't collide with each other; display error message as soon as
% one package collision is detected

% Reduce data array to just min and max x, y, and z coordinates
minmaxXYZCoords = [submit(:,1) min(submit(:,2:3:end),[],2) max(submit(:,2:3:end),[],2) ...
    min(submit(:,3:3:end),[],2) max(submit(:,3:3:end),[],2) ...
    min(submit(:,4:3:end),[],2) max(submit(:,4:3:end),[],2)];

% Sort by max z-coord for each present
minmaxXYZSorted = sortrows(minmaxXYZCoords,-7); % -7 sorts by col 7 in descending order

% Compare present i against other presents, checking for collision
for i = 1:numPresentsSubmit
    for j = i+1:numPresentsSubmit
        % Test for collision on z-axis first, since sorted
        minZi = minmaxXYZSorted(i,6); 
        maxZj = minmaxXYZSorted(j,7); 
        if minZi > maxZj
            % No overlap on z-axis implies no collision
            break
        end
        
        % Test for collision on x-axis
        minXi = minmaxXYZSorted(i,2);        
        minXj = minmaxXYZSorted(j,2);
        maxXi = minmaxXYZSorted(i,3); 
        maxXj = minmaxXYZSorted(j,3);         
        if or(maxXi < minXj, minXi > maxXj)
            % No overlap on x-axis implies no collision
            continue
        end
        
        % Test for collision on y-axis
        minYi = minmaxXYZSorted(i,4); 
        minYj = minmaxXYZSorted(j,4); 
        maxYi = minmaxXYZSorted(i,5); 
        maxYj = minmaxXYZSorted(j,5); 
        if or(maxYi < minYj, minYi > maxYj)
            % No overlap on y-axis implies no collision
            continue
        end
        
        % Overlap on x, y, and z axes indicates collision
        fprintf('Collision check FAILED: packages %d and %d collided\n',minmaxXYZSorted(i,1),minmaxXYZSorted(j,1));
        return
    end
end
fprintf('Collision check PASSED: No packages collided\n');

%% Computing the Evaluation Metric
% How well Santa's sleigh is packed will be judged by the overall
% compactness of the packing and the ordering of the presents: 
% metric  = 2 * max(z-coordinates) + sigma(order)

% Ideal order is the original order
idealOrder = input(:,1); 

% Determine the max z-coordinate; this is the max height of the sleigh
maxZ = max(max(submit(:,4:3:end)));

% Go down the layers from top to bottom, reorder presents in numeric order
% for each layer
maxZCoord = zeros(numPresentsSubmit,2);
for i = 1:numPresentsSubmit
    maxZCoord(i,1) = submit(i);
    maxZCoord(i,2) = max(submit(i,4:3:end));
end
maxzCoordSorted = sortrows(maxZCoord,[-2 1]); %sort max z-coord for each present
reOrder = maxzCoordSorted(:,1);

% Compare the new order to the ideal order
order = sum(abs(idealOrder - reOrder));

% Compute metric
metric = 2*maxZ + order;
fprintf('Evaluation metric score is %d\n', metric);