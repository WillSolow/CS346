% FinalProject_whsolo_sorhom_ex3.m
% Will Solow and Skye Rhomberg
% CS346 - Spring 2020
% Final Project - Wildfire Simulation

% When run, this file simulates the spread of a wildfire in accordance to
% the model described in section 10.3 with the addition of lightning
% strikes, a spread function based off of the amount of trees burning
% around it, and tree growth. Also, this simulation models steady wind from
% a set direction and global rainfall

num_iterations = 50;
neighborhood_size = 4;

% Initializing Constants
EMPTY = 0; % the cell is empty and not containing tree
TREE = 1; % the cell contains a tree that is not burning
BURNING = 2; % the cell contains a tree that is burning

% probability of a tree occupying a cell
prob_tree = .8;
% probability of tree starting as burning if the cell contains a tree
prob_burning = .0005;
% probability of a tree not catching fire at a time step
prob_immune = .25;
% used for rainfall vs no rainfall, default is no rainfall
immunity = prob_immune;
% the probability that a tree grows on an empty cell
prob_grow = .01;
% the probability that a lightning strikes a tree
prob_lightning = .0001;

% wind direction as a directional vector
% first coordinate is east-west, where positive is westerly wind
% second coordinate is north-south, where positive is southerly wind
% values between -1 and 1
wind_dir = [0.75 -0.4];

% simulate global rainfall based on start and end times. rainfall is
% modeled by increasing immunity of trees to catching on fire
rainfall_immunity = .5;
% array of starts and stops in rainfall. Can have as many as want as long 
% as less than num_iterations
rainfall_switches = [10 30];
rainfall_on(1) = 0;

% width and length of forest
forest_rows = 60; % height of the forest 
forest_cols = 60; % width of the forest
x = 1:forest_rows;
y = 1:forest_cols;

% initialize random seed so that results can be reproduced
seed = 1;
rng(seed);

% initialize the forest
forest = init_forest(forest_rows, forest_cols, prob_tree, prob_burning);

% create extended forest to support buffered area
% absorbent boundary to simulate the forest in an area with boundary
% conditions
ext_forest = zeros(forest_rows+2 ,forest_cols+2);
ext_forest(2:forest_rows+1,2:forest_cols+1) = forest;

forest_list{1} = forest;
ext_forest_list{1} = ext_forest;

for i = 1:num_iterations
    % get current forest and extended forest grid
    forest = forest_list{i};
    ext_forest = ext_forest_list{i};
    
    % switch between rainfall and no rainfall globally by switching
    % immunity of trees burning
    if any(rainfall_switches == i)
        immunity = ((immunity == rainfall_immunity)*prob_immune) ...
            + ((immunity == prob_immune)*rainfall_immunity);
    end
    
    % apply spread function to calculate tree burning
    forest = spread(forest,ext_forest,forest_rows,forest_cols,immunity, ...
        prob_grow, prob_lightning, neighborhood_size, wind_dir, EMPTY, TREE, BURNING);
    
    % update extended forest
    ext_forest(2:forest_rows+1,2:forest_cols+1) = forest;
    
    % update grid lists
    forest_list{i+1} = forest;
    ext_forest_list{i+1} = ext_forest;
    % get rainfall array for graphing (1) if rainfall is on
    rainfall_on(i+1) = (immunity == rainfall_immunity);
end

% initializes the forest to a square grid with inputs for the probability
% of tree density and the probability that a tree is burning
function forest = init_forest(forest_rows, forest_cols , prob_tree, prob_burning)
    % create a random grid of doubles in the range (0,1)
    rand_grid = rand(forest_rows,forest_cols);
    % if value is less than tree probability, assign a one
    trees = (rand_grid < prob_tree);
    % prob_tree*prob_burning is the probability of a burning square and as
    % prob_burning is always less than 1,if this evaluates to a 1 then
    % trees will as well
    burning = (rand_grid < prob_tree*prob_burning);
    % by pointwise summing trees and burning, we obtain values of 0, 1, 2
    % (EMPTY, TREE, BURNING) to obtain a forest with burning trees
    forest = trees + burning;
end

% controls the spread of the fire and returns EMTPY, TREE or BURNING
% depending on the neighbors in the von Neumann neighborhood
function forest = spread(forest,ext_forest,forest_rows,forest_cols,prob_immune, ...
    prob_grow, prob_lightning, neighborhood_size, wind_dir, EMPTY, TREE, BURNING)
    % get the range of the extended grid with the padding of the extended
    % grid
    ext_forest_rows = forest_rows+2;
    ext_forest_cols = forest_cols+2;
    
    % create 4 offset grids for Von Neumann neighborhood the size of forest from
    % extended grid to be used to add together to find the burning neighbors
    % every 1 is exactly a burning tree.
    north_grid = (ext_forest(1:ext_forest_rows-2, 2:ext_forest_cols-1) == BURNING);
    south_grid = (ext_forest(3:ext_forest_rows, 2:ext_forest_cols-1) == BURNING);
    west_grid = (ext_forest(2:ext_forest_rows-1, 1:ext_forest_cols-2) == BURNING);
    east_grid = (ext_forest(2:ext_forest_rows-1, 3:ext_forest_cols) == BURNING);

    % calculate wind direction offset for each directional grid
    % the grid value (no wind) plus the directional strentgh times actual
    % direction
    % 0 out negative values to keep each cell in the range [0,2] to ensure
    % that no cell contributes negatively to the summation of the burning
    % cells
    % directions are all normalized with cosine and offsetted by their
    % direction with respect to the center cell
    north_grid = north_grid - (wind_dir(2) .* (north_grid > 0));
    south_grid = south_grid + (wind_dir(2) .* (south_grid > 0));
    west_grid = west_grid + (wind_dir(1) .* (west_grid > 0));
    east_grid = east_grid - (wind_dir(1) .* (east_grid > 0));
    
    % sum all burning neighbors to receive value 0-neighborhood_size to be used in
    % probability analysis of burning
    burning_neighbors = north_grid + south_grid + east_grid + west_grid; 
    
    % calculate what trees are remaining, if a tree is burning it goes to
    % empty
    trees_remaining = (forest == TREE);
    
    % empty cells used to calculate tree growth
    empty_cells = (forest == EMPTY);
    % if a cell is empty and the probability is a new tree, assign a new
    % tree to that cell spot
    new_trees = empty_cells .* (rand(forest_rows,forest_cols) < prob_grow);
    
    % calculates array of all cells with no immunity and burning neighbors
    % note that a tree may or may not be in one of these cells
    nonimmune_cells = (rand(forest_rows,forest_cols) < ((1- prob_immune)...
        + (prob_immune / (neighborhood_size)) * burning_neighbors));
    lightning_cells = (rand(forest_rows,forest_cols) < prob_lightning);
    
    % calculates which new cells are going to be burning based on neighbors
    % and lightning strikes
    nonimmune_burning_cells = nonimmune_cells .* ((burning_neighbors > 0) ...
        | lightning_cells);
    
    % calculates all burning trees (1) and add it to the remaining trees to
    % get all empty, tree or burning cells
    forest = trees_remaining .* nonimmune_burning_cells + trees_remaining ...
        + new_trees;      
end

       