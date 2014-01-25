function PlotSolution(packing, EP)
% PlotSolution - Visually display the box packing solution
%
% Inputs:
%    packing - a matrix of origins, edges
%    EP - a matrix of extreme points

n = size(packing,1);
%plotcube([100 100 100],[0 0 0],0,[0 0 0]);
for i = 1:n
    edges = packing(i, 4:6);
    origin = packing(i, 1:3);
    alpha = 0.2;
    color = [rand rand rand];
    plotcube(edges, origin, alpha, color);
end

% Plot the extreme points
if nargin > 1
    hold on;
    scatter3(EP(:,1), EP(:,2), EP(:,3), 30, 'fill')
    hold off;
end