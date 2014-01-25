%% Set parameters and initialize variables

% Container parameters
containerWidth = 1000; % x-axis of container
containerLength = 1000; % y-axis of container
containerHeight = intmax; % z-axis of container (set to a pre-computed near-optimal value)

% Algorithm parameters
populationSize = 5; % number of solutions in each batch
numPopulations = 2; % number of populations to evolve in parallel
numGenerations = 2; % number of times to evolve the population
elitism = 0.10; % percentage of best solutions to carray to next generation
mutants = 0.20; % percentage of new mutants to insert into next generation
crossover = 0.75; % probability the offspring takes on the ith componenet of the elite parent
exchangeFrequency = 5; % generation gap between inter-population communication
exchangeAmount = 2; % number of elite individuals to insert during inter-population communication

% Recommended algorithm parameters
% for toy example of 100^3 bin and 200 boxes
% ---------------------------------
% populationSize = [10, 40] * numBoxes
% numPopulations = 5
% numGenerations = ???
% elitism = [0.10, 0.25]
% mutants = [0.15, 0.30]
% crossover = [0.70, 0.80]
% exchangeFrequency = 15
% exchangeAmount = 2

% Initialization
fitnessLog = zeros(numGenerations, 2);
timeLog = zeros(numGenerations,1);
rng(555); % set random seed

% Email parameters
setpref('Internet','E_mail','bellaswanislife@gmail.com');
setpref('Internet','SMTP_Server','smtp.gmail.com');
setpref('Internet','SMTP_Username','bellaswanislife@gmail.com');
setpref('Internet','SMTP_Password','lncFpD8pfcMgdNz6NdfD');
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');

if matlabpool('size') ~= 0
    matlabpool close;
end
matlabpool open;
tic;

%% Import the data
boxes = csvread('../../../Data/presents.csv', 1, 0); % BoxID, width, length, height
boxes = int32(boxes); % convert to ints
boxes = boxes(1:1000,:); % for testing
n = size(boxes, 1);
bestSolution = zeros(numGenerations, 3*n+1);

%% Execute algorithm

% Randomly create intial populations, append extra column for fitness value
populations = cat(3, rand(numPopulations, populationSize, 3*n), zeros(numPopulations, populationSize));

% Begin
tic;
h = waitbar(0,'Starting...');
for i = 1:numGenerations    
    fprintf('Entered generation %i\n', i);
    % For each population
    for j = 1:numPopulations
        fprintf('\tProcessing population %i\n', j);
        population = squeeze(populations(j,:,:));

        % For each individual
        solutionStorer = zeros(1,populationSize);
        parfor k = 1:populationSize
            % Skip this step if elite and fitness already calculated
            if population(k,end) ~= 0
                continue;
            end
            % Decode genome
            solution = Decode(squeeze(population(k,:)), boxes, containerWidth, containerLength, containerHeight);            
            % Calculate fitness
%             populations(j,k,3*n+1) = Metric(solution);
            solutionStorer(k) = Metric(solution);
        end
        populations(j,:,3*n+1) = solutionStorer;
        % Track progress
        waitbar(i*j/numGenerations/numPopulations, h, sprintf('%d%% along...',floor(i*j/numGenerations/numPopulations*100)))
    end
    
    % Log fitnesses
    consolidated = reshape(populations, numPopulations*populationSize, 3*n+1);
    sorted = sortrows(consolidated, 3*n+1);
    fitnessLog(i,1) = sorted(1,3*n+1);
    fitnessLog(i,2) = mean(sorted(:,3*n+1));
    bestSolution(i,:) = sorted(1,:)';      
    
    % For each population
    exchangedSolutions = sorted(1:exchangeAmount,:);
    for j = 1:numPopulations
        % Create next generation
        population = squeeze(populations(j,:,:));
        evolvedPopulation = Evolve(population, elitism, mutants, crossover);
        
        % Exchange information between populations every <exchangeFrequency> 
        % generations by inserting the best <exchangeAmount> solutions into all
        % populations
        if mod(i,exchangeFrequency) == 0
            for k=1:exchangeAmount
                % If the solution does not already exist in this population
                if ~any(ismember(population, exchangedSolutions(k,:), 'rows'));
                    evolvedPopulation(populationSize-k+1,:) = exchangedSolutions(k,:);
                end
            end
        end
        
        % Add evolvedPopulation
        populations(j,:,:) = evolvedPopulation;
    end
    
    % After each generation, send an email and save the best solution
    [~, idx] = min(fitnessLog(1:i,1));
    subject = sprintf('GA Update - Generation %i',i);
    body = sprintf('Best fitness: %d \nAveragefitness: %d', fitnessLog(i,1), fitnessLog(i:2));
    sendmail('charleslee592@gmail.com',subject,body)
    
    solution = bestSolution(idx,:);
    solution = Decode(solution, boxes, containerWidth, containerLength, containerHeight);
    subfile = strcat('C:\Users\Charles\Dropbox\MATLAB\',strrep(strcat(num2str(bestFitness), ' - GA (', datestr(now), ').csv'), ':', '.'));
    fileID = fopen(subfile, 'w');
    headers = {'PresentId','x1','y1','z1','x2','y2','z2','x3','y3','z3','x4','y4','z4','x5','y5','z5','x6','y6','z6','x7','y7','z7','x8','y8','z8'};
    fprintf(fileID,'%s,',headers{1,1:end-1});
    fprintf(fileID,'%s\n',headers{1,end});
    fprintf(fileID,'%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n',solution');
    fclose(fileID); 
end
close(h)

%% Output Solution
[bestFitness, idx] = min(fitnessLog(:,1));
solution = bestSolution(idx,:);
solution = Decode(solution, boxes, containerWidth, containerLength, containerHeight);
subfile = strrep(strcat('num2str(bestFitness), ' - GA (', datestr(now), ').csv'), ':', '.');
% subfile = strrep(strcat('../../../Submissions/', num2str(bestFitness), ' - GA (', datestr(now), ').csv'), ':', '.');
fileID = fopen(subfile, 'w');
headers = {'PresentId','x1','y1','z1','x2','y2','z2','x3','y3','z3','x4','y4','z4','x5','y5','z5','x6','y6','z6','x7','y7','z7','x8','y8','z8'};
fprintf(fileID,'%s,',headers{1,1:end-1});
fprintf(fileID,'%s\n',headers{1,end});
fprintf(fileID,'%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n',solution');
fclose(fileID);

matlabpool close;
toc

subject = sprintf('GA Update - Complete!');
body = sprintf('The algorithm finished running!\nIt took %d',toc);
sendmail('charleslee592@gmail.com',subject,body)