function [newPopulation] = Evolve(population, elitism, mutants, crossover)
    % elitism - percentage of best solutions to carray to next generation
    % mutants - percentage of new mutants to insert into next generation
    % crossover - probability the offspring takes on the ith componenet of the elite parent
    
    % Initialize newPopulation
    [n, m] = size(population);
    newPopulation = zeros(n, m);
    
    % Sort by fitness
    population = sortrows(population, m);

    % Carry over elite individuals
    numElites = ceil(elitism * n);
    elites = population(1:numElites,:);
    nonElites = population(numElites+1:end,:);
    numNonElites = size(nonElites,1);
    newPopulation(1:numElites,:) = elites;
    
    % Create mutants
    numMutants = floor(mutants * n);
    % Remember to leave fitness as zero
    newPopulation(numElites+1:numElites+numMutants,1:m-1) = rand(numMutants, m-1);
    
    % Crossover to create the rest of the population
    currentIndex = numMutants + numElites + 1;
    for i=currentIndex:n
        randomElite = elites(randi(numElites,1),:);
        randomNonElite = nonElites(randi(numNonElites,1),:);
        mask = double(rand(1,m)<crossover);
        inversemask = double(not(boolean(mask)));
        crossed = randomElite.*mask + randomNonElite.*inversemask;
        newPopulation(i,:) = crossed;
        % Remember to set fitness to zero
        newPopulation(i,m) = 0;
    end
end