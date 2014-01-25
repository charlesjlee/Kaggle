function PlotSolution2(packing, EMS)
% PlotSolution - Visually display the box packing solution
%
% Inputs:
%    packing - a matrix of coordinates
%              'PresentId','x1','y1','z1',
%              'x2','y2','z2','x3','y3','z3',
%              'x4','y4','z4','x5','y5','z5',
%              'x6','y6','z6','x7','y7','z7',
%              'x8','y8','z8'

n = size(packing,1);
plotcube([1000 1000 1000],[0 0 0],0,[0 0 0]);

% Reduce data array to just min and max x, y, and z coordinates
minmaxXYZCoords = [packing(:,1) min(packing(:,2:3:end),[],2) max(packing(:,2:3:end),[],2) ...
    min(packing(:,3:3:end),[],2) max(packing(:,3:3:end),[],2) ...
    min(packing(:,4:3:end),[],2) max(packing(:,4:3:end),[],2)];

for i = 1:n
    % plotcube([5 5 5],[20 20 20],.8,[0 0 1]);
    width = minmaxXYZCoords(i,3) - minmaxXYZCoords(i,2);
    length = minmaxXYZCoords(i,5) - minmaxXYZCoords(i,4);
    height = minmaxXYZCoords(i,7) - minmaxXYZCoords(i,6);
    edges = [width length height];
    origin = [minmaxXYZCoords(i,2) minmaxXYZCoords(i,4) minmaxXYZCoords(i,6)];
    alpha = 0.2;
    color = [rand rand rand];
    plotcube(edges, origin, alpha, color);
end

% Plot EMS points
if nargin > 1
    hold on;
    points = EMS(~all(EMS==0,2),1:3);
    scatter3(points(:,1), points(:,2), points(:,3), 30, 'fill')
    hold off;
end
