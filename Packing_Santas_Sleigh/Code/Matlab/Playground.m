%MATLAB_Metric_v2('../../Data/presents.csv', '../../Submissions/MATLAB_Packing_Submission_File.csv')

packing = [5 5 5 20 20 20];
EP = magic(3);
PlotSolution(packing, EP);

% plotcube([25 25 25],[0 0 0],0,[0 0 0]);
PlotSolution(double(placedBoxes(1:end,2:end)), EP);
PlotSolution(double(placedBoxes(1:end,2:end)));

points = [2 207 0;
          2 207 5;
          75 3 0;
          75 0 5;
          2 0 243;
          2 3 243];
hold on;
scatter3(p(:,1), p(:,2), p(:,3));
hold off;