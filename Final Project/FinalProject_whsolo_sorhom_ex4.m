% FinalProject_whsolo_sorhom_ex4.m
% Will Solow and Skye Rhomberg
% CS346 - Spring 2020
% Final Project - Wildfire Simulation

% When run, this model simulates tree ages under the assumption that a
% bigger tree will take longer to grow, that it will be less likely to
% catch fire, and when it does it burns for longer. 
% Additionally, we include lightning strikes, rainfall, and wind direction 
% as in previous scripts

% TO Run: press F5 and then call show_forest_age with forest_list,
% burning_list and rainfall_on as arguments

num_iterations = 50; % simulation length
nbhd_size = 4; % neighborhood size (4 for von neumann, 8 for moore)

% Initializing Constants
EMPTY = 0; % the cell is empty and not containing tree
SAPLING = 1; % the cell contains a new sapling
YOUNG = 2; % the cell contains a cell young tree
OLD = 3; % the cell contains a tree that is old (mid sized to large)
ANCIENT = 4; % the cell contains a large ancient tree

% probability of a tree occupying a cell. controls density of forest
prob_tree = .6;
% the probability that a new tree grows
prob_grow = .02;
% the speed at which the forest grows 
forest_growth = .1;
% the age of the forest. In the range (0,1) 1 is all old trees 0 is all
% saplings
forest_age = .5;
% probability of tree starting as burning if the cell contains a tree
prob_burning = .0005;
% probability of a tree not catching fire at a time step
prob_immune = .25;
% used for rainfall vs no rainfall, default is no rainfall
immunity = prob_immune;
% the probability that a lightning strikes a tree
prob_lightning = .0001;

% wind direction as a directional vector
% first coordinate is east-west, where positive is westerly wind
% second coordinate is north-south, where positive is southerly wind
% values between -1 and 1
wind_dir = [0 0];

% simulate global rainfall based on start and end times. rainfall is
% modeled by increasing immunity of trees to catching on fire
rainfall_immunity = .5;
% array of starts and stops in rainfall. Can have as many as want as long 
% as less than num_iterations
rainfall_switches = [];
rainfall_on(1) = 0;

% width and length of forest
forest_rows = 30; % height of the forest 
forest_cols = 30; % width of the forest

% initialize random seed so that results can be reproduced
seed = 1;
rng(seed);

% initialize the forest
[forest,burning] = init_forest(forest_rows, forest_cols,prob_tree, ...
    prob_burning,forest_age);

% create the burning area and a buffered absorbent boundary to simulate 
% the fire spread
ext_burning = zeros(forest_rows+2 ,forest_cols+2);
ext_burning(2:forest_rows+1,2:forest_cols+1) = burning;

% keep track of all arrays
forest_list{1} = forest;
burning_list{1} = burning;
ext_burning_list{1} = ext_burning;

% main simulation loop
for i = 1:num_iterations
    % get current forest and extended forest grid
    forest = forest_list{i};
    burning = burning_list{i};
    ext_burning = ext_burning_list{i};
    
    % switch between rainfall and no rainfall globally by switching
    % immunity of trees burning
    % flip immunity when index falls in rainfall switches
    if any(rainfall_switches == i)
        immunity = ((immunity == rainfall_immunity) * prob_immune) ...
            + ((immunity == prob_immune) * rainfall_immunity);
    end
    
    % apply spread function to calculate tree burning
    [forest,burning] = spread(forest,burning,ext_burning,forest_rows, ...
    forest_cols,forest_growth,immunity,prob_grow,prob_lightning, ...
        nbhd_size,wind_dir,EMPTY,ANCIENT);
    
    % update extended forest
    ext_burning(2:forest_rows+1,2:forest_cols+1) = burning;
    
    % update grid lists
    forest_list{i+1} = forest;
    burning_list{i+1} = burning;
    ext_burning_list{i+1} = ext_burning;
    % get rainfall array for graphing (1) if rainfall is on
    rainfall_on(i+1) = (immunity == rainfall_immunity);
end

% initialize forest and burning arrays
% inputs:
%   forest_rows,forest_cols : size of simulated forest
%   prob_tree : initial chance of a cell having a tree
%   prob_burning : initial chance of a cell being on fire
%   forest_age : controls frequency of different ages of trees
function [forest,burning] = init_forest(forest_rows,forest_cols, ... 
    prob_tree,prob_burning,forest_age)
    % create a random grid of doubles in the range (0,1)
    rand_grid = rand(forest_rows,forest_cols);
    % if value is less than tree probability, assign a one. Then the
    % probability of an older tree is proportional to the forest age. Note
    % that if forest_age is one then all arrays will have a tree in them
    sapling_tree = (rand_grid < prob_tree);
    young_tree = (rand_grid < prob_tree * forest_age);
    old_tree = (rand_grid < prob_tree * forest_age^2);
    ancient_tree = (rand_grid < prob_tree * forest_age^3);
    
    % summing these arrays gives us values 0-4 with 0 being an empty cell
    % and 4 being an ancient tree. This will ensure that if there is an
    % ancient tree the probability will ensure that all the other arrays in
    % that cell are 1
    forest = sapling_tree + young_tree + old_tree + ancient_tree;
    
    % prob_tree*prob_burning is the probability of a burning square and as
    % prob_burning is always less than 1, if this evaluates to a 1 then
    % trees will as well
    % this burning array keeps track of what trees are on fire
    burning = (rand_grid < prob_tree * prob_burning);
end

% calculate new forest and burning arrays reflecting spread of fire
% inputs:
%   forest, burning : current forest and burning arrays
%   ext_burning : burning array with padding for neighbor calculations
%   forest_rows, forest_cols : size of simulated forest
%   forest_growth : rate at which younger trees grow to older
%   immunity : controls chances of trees to catch fire
%   prob_grow : chance of an empty cell sprouting a new tree
%   prob_lightning : chance of a lightning strike in a cell
%   nbhd_size : neighborhood size. default is 4 (von neumann nbhd)
%   wind_dir : vector of wind direction e-w, n-s
%   EMPTY, ANCIENT : initialization constants for empty and ancient cells
function [forest,burning] = spread(forest,burning,ext_burning, ...
    forest_rows,forest_cols,forest_growth,immunity,prob_grow,...
    prob_lightning,nbhd_size,wind_dir,EMPTY,ANCIENT)
    % get the range of the extended grid with the padding of the extended
    % grid
    ext_burning_rows = forest_rows+2;
    ext_burning_cols = forest_cols+2;
    
    % create 4 offset grids for Von Neumann neighborhood the size of forest 
    % from extended grid to be used to add together to find the burning 
    % neighbors from the burning array
    north_grid = ext_burning(1:ext_burning_rows-2, 2:ext_burning_cols-1);
    south_grid = ext_burning(3:ext_burning_rows, 2:ext_burning_cols-1);
    west_grid = ext_burning(2:ext_burning_rows-1, 1:ext_burning_cols-2);
    east_grid = ext_burning(2:ext_burning_rows-1, 3:ext_burning_cols);
    
    % calculate wind direction offset for each directional grid
    % the grid value (no wind) plus the directional strentgh times actual
    % direction
    % 0 out negative values to keep each cell in the range [0,2] to ensure
    % that no cell contributes negatively to the summation of the burning
    % cells
    north_grid = north_grid - (wind_dir(2) .* (north_grid > 0));
    south_grid = south_grid + (wind_dir(2) .* (south_grid > 0));
    west_grid = west_grid + (wind_dir(1) .* (west_grid > 0));
    east_grid = east_grid - (wind_dir(1) .* (east_grid > 0));
    
    % sum all burning neighbors to receive value 0-neighborhood_size to 
    % be used in probability analysis of burning
    burning_neighbors = north_grid + south_grid + east_grid + west_grid;
    
    % calculate what current cells are empty based on the forest grid
    empty_cells = (forest == EMPTY);
    % if a cell is empty and the probability is a new tree, assign a new
    % tree to that cell spot
    new_trees = empty_cells .* (rand(forest_rows,forest_cols) < prob_grow);
    
    % calculates a random array and divides by the oldest tree age to
    % normalize values into the range 0-4. Then pointwise multiply by
    % forest under the assumption that older trees are less likely to burn
    % filter by trees not currently burning : obviously burning trees
    % aren't immune, they are added in later
    % note that with 4 burning neighbors, all trees will burn
    % this array represents the cells that are not immune to burning
    nonimmune_cells = ((rand(forest_rows,forest_cols)/ANCIENT).*forest ...
        < ((1- immunity) + (immunity / nbhd_size) * burning_neighbors)) ...
        .* (~burning);
    
    % the chance that lightning strikes a spot
    lightning_cells = (rand(forest_rows,forest_cols) < prob_lightning);
    
    % calculates what new cells are going to be burning at the next time
    % step (note this does not account for what trees are burning)
    nonimmune_burning_cells = nonimmune_cells .* ...
    ((burning_neighbors > 0) | lightning_cells);
    
    % update the forest based on subtracting the burning cells from the
    % forest under the assumption that an ANCIENT tree takes its steps to
    % burn
    burnt_forest = forest - burning;
    % calculate which trees will be burning at the next time step
    % newly burning cells plus cells burning last time step
    % except where burnt forest is empty, i.e. trees have fully burned
    burning_trees = (nonimmune_burning_cells + burning) .* ...
        (burnt_forest ~= EMPTY);
    
    % calculate tree growth based off of the rate of growth function;
    % if the cell is burning a tree or empty cannot grow
    tree_growth = (rand(forest_rows,forest_cols) ...
        < rate_of_growth(forest_growth,forest,ANCIENT) ...
        .* (~burning) .* (forest ~= EMPTY));
    
    % trees are a sum of the trees that burnt plus the trees that grew and
    % the new saplings; tree_growth ages existing trees,
    % new_trees grows sapling from empty ground
    forest = burnt_forest + tree_growth + new_trees;
    % update burning
    burning = burning_trees;
end

% calculate the change that a forest grows:
% divide forest_growth by (oldest tree value - 1) to normalize forest growth
% calculates rate of growth linearly with no chance of an ancient tree
% growing
function growth = rate_of_growth(forest_growth, forest, ANCIENT) 
    growth = forest_growth/(ANCIENT-1) * (ANCIENT-forest);
end