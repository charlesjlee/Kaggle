function EMS = UpdateEMS(EMS, EMSindex, boxes, width, length, height, submission, iteration)
    % Grab EMS values
    minEMS = EMS(EMSindex,1:3);
    maxEMS = EMS(EMSindex,4:6);
    
    % Void EMS that was just used
    EMS(EMSindex,:) = zeros(1,6);

    % Get origin and dimensions of each placed box
%     placedBoxes = submission(all(submission,2),:);
%     placedBoxes(:,5) = placedBoxes(:,14) - placedBoxes(:,5);
%     placedBoxes(:,6) = placedBoxes(:,6) - placedBoxes(:,3);
%     placedBoxes(:,7) = placedBoxes(:,10) - placedBoxes(:,7);
    
    % Generate six new EMS's
    newEMS = [minEMS(1)+width minEMS(2) minEMS(3) maxEMS(:)';
              minEMS(1) minEMS(2)+length minEMS(3) maxEMS(:)';
              minEMS(1) minEMS(2) minEMS(3)+height maxEMS(:)'];    
    
% newEP = zeros(6,3);




%     maxBound = repmat(-1, 1, 6);
%     newEP = zeros(6,3);
    %     for i = 1:size(placedBoxes,1)
%         x_i = placedBoxes(i,2);
%         y_i = placedBoxes(i,3);
%         z_i = placedBoxes(i,4);
%         width_i = placedBoxes(i,5);
%         length_i = placedBoxes(i,6);
%         height_i = placedBoxes(i,7);
%         if x_i + width_i > maxBound(1)
%             newEP(1,:) = [x_i + width_i, y + length, z];
%             maxBound(1) = x_i + width_i;
%         end
%         if z_i + height_i > maxBound(2)
%             newEP(2,:) = [x, y + length, z_i + height_i];
%             maxBound(2) = z_i + height_i;
%         end
%         if y_i + length_i > maxBound(3)
%             newEP(3,:) = [x + width, y_i + length_i, z];
%             maxBound(3) = y_i + length_i;
%         end
%         if z_i + height_i > maxBound(4)
%             newEP(4,:) = [x + width, y, z_i + height_i];
%             maxBound(4) = z_i + height_i;
%         end
%         if x_i + width_i > maxBound(5)
%             newEP(5,:) = [x_i + width_i, y, z + height];
%             maxBound(5) = x_i + width_i;
%         end
%         if y_i + length_i > maxBound(6)
%             newEP(6,:) = [x, y_i + length_i, z + height];
%             maxBound(6) = y_i + length_i;
%         end
%     end
%     newEMS = [newEP repmat(maxEMS(:)',6,1)];
%     disp(newEMS(:,1:5));

    % Eliminate void and redundant EMS
    for i=1:3
        % Eliminate EMS of infinite thin-ness
        if any(newEMS(i,1:3)==newEMS(i,4:6))
            newEMS(i,:) = zeros(1,6);
        end
        % Eliminate EMS completely inscribed in others
%         for j=1:size(EMS,1)
%             mask = logical(newEMS(i,1)>=EMS(:,1)) & logical(newEMS(i,2)>=EMS(:,2)) & logical(newEMS(i,3)>=EMS(:,3)) ...
%                    + logical(newEMS(i,4)<=EMS(:,4)) & logical(newEMS(i,5)<=EMS(:,5)) & logical(newEMS(i,6)<=EMS(:,6));
%             if any(mask)
%                 newEMS(i,:) = zeros(1,6);
%             end
%         end
    end

    % Update list of EMS
    EMS(3*iteration+1:3*iteration+3,:) = newEMS;
    
    % Eliminate EMS with volume smaller than boxes remaining
    smallestVolume = min(boxes(iteration:end,1) .* boxes(iteration:end,2) .* boxes(iteration:end,3));
    volumes = (EMS(:,4)-EMS(:,1)) .* (EMS(:,5)-EMS(:,2)) .* (EMS(:,6)-EMS(:,3));
    mask = repmat(volumes > smallestVolume,1,6);
    EMS = EMS .* mask;

    % Eliminate EMS with smallest dimension smaller than smallest
    % dimension of boxes remaining
%     smallestDimension = min([boxes(ID:end,1); boxes(ID:end,2); boxes(ID:end,3)]);
%     dimensions = [EMS(:,4)-EMS(:,1) EMS(:,5)-EMS(:,2) EMS(:,6)-EMS(:,3)];
%     mask = repmat(dimensions < smallestDimension,1,6);
%     EMS = EMS .* mask;
    
end