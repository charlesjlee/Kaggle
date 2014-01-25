%% Read in the file
firstRow = 1;
firstCol = 0;
presents = csvread('../../Data/presents.csv', firstRow, firstCol);
IDs = presents(:,1);
Width = presents(:,2);
Length = presents(:,3);
Height = presents(:,4);
clear presents

%% Construct XML
subfile = strcat('../../Data/presents');
fileID = fopen(subfile, 'w');

% XML type 1
% -----------
% fprintf(fileID, '<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>\n');
% fprintf(fileID, '<!DOCTYPE boost_serialization>\n');
% fprintf(fileID, '<boost_serialization signature="serialization::archive" version="10">\n');
% 
% for i = 1:10%length(IDs)
%     fprintf(fileID, '<cuboid>\n');
%     fprintf(fileID, '\t<width>%i</width>\n', Width(i));
%     fprintf(fileID, '\t<height>%i</height>\n', Height(i));
%     fprintf(fileID, '\t<depth>%i</depth>\n', Length(i));   
%     fprintf(fileID, '\t<x>0</x>\n');
%     fprintf(fileID, '\t<y>0</y>\n');
%     fprintf(fileID, '\t<z>0</z>\n');
%     fprintf(fileID, '</cuboid>\n');
% end
% fprintf(fileID, '</boost_serialization>');


% XML type 2
% -----------
n = 5;
fprintf(fileID, '%i 1', n);
for i = 1:n
    fprintf(fileID, '%i', IDs(i));    
    fprintf(fileID, ' %i', Width(i));
    fprintf(fileID, ' %i', Height(i));
    fprintf(fileID, ' %i\n', Length(i));   
end

fclose(fileID);