function metric = Metric(solution)
    % Determine the max z-coordinate; this is the max height of the sleigh
    maxZ = max(max(solution(:,4:3:end)));

    % Go down the layers from top to bottom,
    % reorder presents in numeric order for each layer
    maxZCoord = [solution(:,1) max(solution(:,4:3:end),[],2)];
    maxzCoordSorted = sortrows(maxZCoord,[-2 1]); %sort max z-coord for each present
    reOrder = maxzCoordSorted(:,1);

    % Compare the new order to the ideal order
    order = sum(abs(1:size(solution,1) - reOrder));

    % Compute metric
    metric = 2*maxZ + order;
end