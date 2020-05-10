% FinalProject_whsolo_sorhom_show_forest.m
% Will Solow and Skye Rhomberg
% CS346 - Spring 2020
% Final Project - Wildfire Simulation

% calling this function displays the forest fire in sequence 
% inputs: list -- list of CA frames to be plotted
%         interval -- every <interval> frames will be plotted
% call using forest_list from generated final project list

function [] = show_forest(list,interval)
    
    % plot the CA gridsshow_CA_List(extgrid_list,10, 23, 27)
    for i = 1:interval:length(list)
        forest_colormap = [.439 .282 .239
                           .043 .588 .443
                           1.00 .341 .165];
                       
        colormap(forest_colormap);
            
        % gets data to be plotted
        data = list{i};
       
       % plot the image
       imagesc(data);
       title(sprintf('Wild fire spread\n Frame: %d',i));
       hold;
       axis equal;
       axis tight;
       set(gca,'XTick',[], 'YTick', [])
       
       
       % wait to go to next image
       fprintf('Wating for any key to be pressed\n');
       w = waitforbuttonpress;
end