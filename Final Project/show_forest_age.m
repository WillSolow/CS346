% FinalProject_whsolo_sorhom_show_forest.m
% Will Solow and Skye Rhomberg
% CS346 - Spring 2020
% Final Project - Wildfire Simulation

% calling this function displays the forest fire in sequence 
% inputs: list -- list of CA frames to be plotted
%         rainfall_on -- array of 1's and 0's for rainfall on/off
% call using forest_list from generated final project list

function [] = show_forest(list, rainfall_on)
    
    % plot the CA gridsshow_CA_List(extgrid_list,10, 23, 27)
    for i = 1:length(list)
        forest_colormap = [.439 .282 .239
                           .043 .588 .443
                           1.00 .341 .165];
                       
        colormap(forest_colormap);
            
        % gets data to be plotted
        data = list{i};
       
       % plot the image
       % keeps the data within range EMPTY, TREE, BURNING
       imagesc(data, [0 2]);
       title(sprintf('Wild Fire Spread\n Frame: %d\n Raining: %i',i,rainfall_on(i)));
       hold;
       axis equal;
       axis tight;
       set(gca,'XTick',[], 'YTick', [])
       
       
       % wait to go to next image
       fprintf('Wating for any key to be pressed\n');
       w = waitforbuttonpress;
end