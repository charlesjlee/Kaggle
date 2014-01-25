function submission = Decode(solution, boxes, containerWidth, containerLength, containerHeight)
    % Initialization
    n = (size(solution,2)-1)/3;
    submission = zeros(n,25);
    EMS = zeros(6*n,6);
    EMS(1,4:6) = [containerWidth containerLength containerHeight];
    
    BPS = solution(1:n);
    [~, idx] = sort(BPS);
    BPS = idx;    
    VPH = solution(n+1:2*n);    
    VBO = solution(2*n+1:3*n);       
    
    % Place each box, one-by-one
    for i=1:n
        % Retrieve box info
        ID = boxes(BPS(i),1);
        width = boxes(BPS(i),2);
        length = boxes(BPS(i),3);
        height = boxes(BPS(i),4);
        
        % Select placement heuristic and place box
        if VBO(i) == 0
            disp('stop here');
        end
        if VPH(i) > 0.5 % 'Back-Bottom-Left'
            [EMS, EMSindex, width, length, height] = BBL(EMS, width, length, height, VBO(i), submission);
        else % 'Back-Left-Bottom'
            [EMS, EMSindex, width, length, height] = BLB(EMS, width, length, height, VBO(i), submission);
        end
        
        % Update submission
        x = EMS(EMSindex,1);
        y = EMS(EMSindex,2);
        z = EMS(EMSindex,3);
        submission(i,:) = [ID ...
                           x y z ...
                           x y+length z ...
                           x y z+height ...
                           x y+length z+height ...
                           x+width y z ...
                           x+width y+length z ...
                           x+width y z+height ...
                           x+width y+length z+height];
                       
        % Update EMS's
        if i == 1
            % Special case
            maxEMS = EMS(1,4:6);
            EMS(1:3,:) = [0 0 height maxEMS; ...
                          0 length 0 maxEMS; ...
                          width 0 0 maxEMS]; 
        else
            EMS = UpdateEMS(EMS, EMSindex, boxes, width, length, height, submission, i);        
        end
    end
    
    % Plot solution
%     PlotSolution2(submission,EMS);    
%     display('hello');
    
end