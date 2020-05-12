% FinalProject_whsolo_sorhom_show_forest.m
% Will Solow and Skye Rhomberg
% CS346 - Spring 2020
% Final Project - Wildfire Simulation

% calling this function displays the forest fire in sequence 
% inputs: forest_list -- list of forest frames to be plotted
%         rainfall_on -- array of 1's and 0's for rainfall on/off
% call using forest_list from generated final project list
function [] = show_forest_rain(forest_list, rainfall_on)
    
    % Color Map
    % colors correspond with initializing constants in ex1-ex3
    forest_colormap = [.439 .282 .239
                       .043 .588 .443
                       1.00 .341 .165];
                       
    colormap(forest_colormap);
    
    % last color in map is always fire color
    FIRE_COLOR = size(forest_colormap,1);
    
    % main plotting loop
    for i = 1:length(forest_list)  
        % gets data to be plotted
        data = forest_list{i};
       
       % plot the image
       % keeps color mapping constant so fire is always
       % last color in colormap
       imagesc(data, [0 FIRE_COLOR]);
       title(sprintf('Wild Fire Spread\n Frame: %d\n Raining: %i', ...
           i,rainfall_on(i)));
       hold;
       axis equal;
       axis tight;
       % Remove Tick Labels
       set(gca,'XTick',[], 'YTick', [])
       
       % wait to go to next image
       fprintf('Wating for any key to be pressed\n');
       w = waitforbuttonpress;
    end
end