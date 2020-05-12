% FinalProject_whsolo_sorhom_ex1.m
% Will Solow and Skye Rhomberg
% CS346 - Spring 2020
% Final Project - Wildfire Simulation

% When run, this file simulates the spread of a wildfire in accordance to
% the model described in section 10.3 of Into To Computational Sciences
% based on the model that a tree will catch fire if its neighbors are on
% fire

% TO Run: press F5 and then call show_forest with forest_list, as arguments

num_iterations = 50; % simulation length

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

% width and length of forest
forest_rows = 60; % height of the forest 
forest_cols = 60; % width of the forest

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

% keep track of arrays
forest_list{1} = forest;
ext_forest_list{1} = ext_forest;

% main simulation loop
for i = 1:num_iterations
    % get current forest and extended forest grid
    forest = forest_list{i};
    ext_forest = ext_forest_list{i};
    
    % apply spread function to calculate tree burning
    forest = spread(forest,ext_forest,forest_rows,forest_cols, ...
        prob_immune,TREE,BURNING);
    
    % update extended forest
    ext_forest(2:forest_rows+1,2:forest_cols+1) = forest;
    
    % update grid lists
    forest_list{i+1} = forest;
    ext_forest_list{i+1} = ext_forest;
end

% initializes the forest to a square grid with inputs for the probability
% of tree density and the probability that a tree is burning
% inputs:
%   forest_rows,forest_cols : size of simulated forest
%   prob_tree : initial chance of a cell having a tree
%   prob_burning : initial chance of a cell being on fire
function forest = init_forest(forest_rows,forest_cols,prob_tree,prob_burning)
    % create a random grid of doubles in the range (0,1)
    rand_grid = rand(forest_rows,forest_cols);
    % if value is less than tree probability, assign a one
    trees = (rand_grid < prob_tree);
    % prob_tree*prob_burning is the probability of a burning square and as
    % prob_burning is always less than 1, if this evaluates to a 1 then
    % trees will as well
    burning = (rand_grid < prob_tree * prob_burning);
    % by pointwise summing trees and burning, we obtain values of 0, 1, 2
    % (EMPTY, TREE, BURNING) to obtain a forest with burning trees
    forest = trees + burning;
end

% controls the spread of the fire and returns EMTPY, TREE or BURNING
% depending on the neighbors in the von Neumann neighborhood
% inputs:
%   forest : current forest array
%   ext_forest : forest array with padding for neighbor calculations
%   forest_rows, forest_cols : size of simulated forest
%   prob_immune : controls chances of trees to catch fire
%   TREE,BURNING : initialization constants
function forest = spread(forest,ext_forest,forest_rows,forest_cols, ...
    prob_immune,TREE,BURNING)
    % get the range of the extended grid with the padding of the extended
    % grid
    ext_forest_rows = forest_rows+2;
    ext_forest_cols = forest_cols+2;
    % create 4 offset grids the size of forest from extended grid to be
    % used to add together to find the burning neighbors
    % every 1 is exactly a burning tree
    north_grid = (ext_forest(1:ext_forest_rows-2, 2:ext_forest_cols-1) == BURNING);
    south_grid = (ext_forest(3:ext_forest_rows, 2:ext_forest_cols-1) == BURNING);
    west_grid = (ext_forest(2:ext_forest_rows-1, 1:ext_forest_cols-2) == BURNING);
    east_grid = (ext_forest(2:ext_forest_rows-1, 3:ext_forest_cols) == BURNING);
    
    % sum all burning neighbors to receive value 0-4 to be used in
    % probability analysis of burning
    burning_neighbors = north_grid + south_grid + east_grid + west_grid;
    
    % calculate what trees are remaining, if a tree is burning it goes to
    % empty
    trees_remaining = (forest == TREE);
    
    % calculates array of all cells with no immunity and burning neighbors
    % note that a tree may or may not be in one of these cells
    nonimmune_cells = (rand(forest_rows,forest_cols) > prob_immune);
    nonimmune_burning_cells = nonimmune_cells .* (burning_neighbors > 0);
    
    % calculates all burning trees and add it to the remaining trees to
    % get all empty, tree or burning cells
    forest = trees_remaining .* nonimmune_burning_cells + trees_remaining;      
end

       