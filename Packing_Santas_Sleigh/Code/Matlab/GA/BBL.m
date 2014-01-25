function [EMS, EMSindex, width, length, height] = BBL(EMS, width, length, height, orientationMask, submission)
    %% Re-order the EMS    
    EMS(EMS==0) = inf;
    sortedEMS = sortrows(EMS, [1 3 2]);
    sortedEMS(sortedEMS==Inf) = 0;
    EMS = sortedEMS;

    %% Select the first EMS that fits the box
    orientations = unique(perms([width length height]),'rows');
    for i=1:size(EMS,1)
        x = EMS(i,1);
        y = EMS(i,2);
        z = EMS(i,3);
        X = EMS(i,4);
        Y = EMS(i,5);
        Z = EMS(i,6);

        % Try each orientation
        orientationFit = x+orientations(:,1)<X & y+orientations(:,2)<Y & z+orientations(:,3)<Z;
        
        % Select an orientation
        if any(orientationFit)
            orientationIndex = ceil(orientationMask * sum(orientationFit));
            findArray = find(orientationFit);
            selectedOrientation = orientations(findArray(orientationIndex),:);
            width = selectedOrientation(1);
            length = selectedOrientation(2);
            height = selectedOrientation(3);
            EMSindex = i;
            return
        end
    end
    
    disp('something went wrong');
end