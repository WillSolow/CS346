% FinalProject_whsolo_sorhom_show_forest.m
% Will Solow and Skye Rhomberg
% CS346 - Spring 2020
% Final Project - Wildfire Simulation

% calling this function displays the forest fire in sequence 
% inputs: forest_list -- list of forest frames to be plotted
%         burning_list -- list of burning frames to be plotted
%         rainfall_on -- array of 1's and 0's for rainfall on/off
% call using forest_list from generated final project list
function [] = show_forest_age(forest_list, burning_list, rainfall_on)
        %forest_colormap = [.439 .282 .239
        %                   .471 1.00 .529   
        %                   .251 .843 .525
        %                   .043 .588 .443
        %                   0.00 .322 .294
        %                   1.00 .341 .165];
        
        % Color Map
        % colors correspond to initializing constants in ex4
        forest_colormap = [.439 .282 .239
                           .129 .722 .443
                           .078 .678 .471
                           .043 .588 .443
                           .012 .459 .376
                           1.00 .341 .165];
                       
        colormap(forest_colormap);
        
        % last color in map is always fire color
        FIRE_COLOR = size(forest_colormap,1);

    % main plotting loop
    for i = 1:length(forest_list)
        % sets the burning trees to color 5 and then adds in the non
        % burning trees as every burning tree is the same color regardless
        % and gets data to be plotted
        data = (FIRE_COLOR * burning_list{i}) ... 
            + (forest_list{i} .* (~burning_list{i}));
       
       % plot the image
       % keep the color mapping constant so that 
       % fire is always the last color in the map
       imagesc(data, [0 FIRE_COLOR]);
       title(sprintf('Wild Fire Spread\n Frame: %d\n Raining: %i', ...
           i,rainfall_on(i)));
       hold;
       axis equal;
       axis tight;
       % remove tick labels
       set(gca,'XTick',[], 'YTick', [])
       
       % wait to go to next image
       fprintf('Wating for any key to be pressed\n');
       w = waitforbuttonpress;
    end
end