% FP_whsolo_sorhom.m
% Will Solow and Skye Rhomberg
% CS346 - Spring 2020
% Final Project - Wildfire Simulation

% This code simulates a basic cellular automata heat diffusion - will be eventually
% extended to a wildfire simulation

nbh_size = 8;
num_iterations = 200;

% Initializing constants
% dimensions of the bar
m = 10;
n = 30;
x = 1:m;
y = 1:n;

% temp constants
amb_temp = 25;
hot_temp = 50;
cold_temp = 0;
r = .1;

% model of the bar in ititial conditions
bar = amb_temp * ones(m,n);
extGrid = amb_temp * ones(m+2,n+2);

% initialize the bar
bar(4:7,1) = hot_temp;
bar(10,20) = hot_temp;
bar(1,8:12) = cold_temp;

% place bar in extended grid
extGrid(2:m+1,2:n+1) = bar;

% list for bar and ext grid
bar_list{1} = bar;
extgrid_list{1} = extGrid;

% sums all neighbors of a point using an annonymous function
neighborSum = @(x,y,extGrid) (extGrid(x+1-1,y+1-1) + extGrid(x+1-1,y+1) + ...
    extGrid(x+1-1,y+1+1) + extGrid(x+1,y+1-1) + ...
    extGrid(x+1,y+1+1) + extGrid(x+1+1,y+1-1) + ...
    extGrid(x+1+1,y+1) + extGrid(x+1+1,y+1+1));

for i = 1:num_iterations
    % get current bar/grid
    bar = bar_list{i};
    extGrid = extgrid_list{i};
    
    % find change in bar and update
    dBar(x,y) = r*(neighborSum(x,y,extGrid) - nbh_size*bar(x,y));
    bar(x,y) = bar(x,y) + dBar(x,y);
    
    % update ext grid
    extGrid(2:m+1,2:n+1) = bar;
    % update grids
    bar_list{i+1} = bar;
    extgrid_list{i+1} = extGrid;
end