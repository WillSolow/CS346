% Function for plotting CA List
% plots images from evolution of a CA

% inputs: list -- list of CA frames to be plotted
%         interval -- every <interval> frames will be plotted
%         upperCmapBound -- lowest value for upper bound on colormap
%         lowerCmapBound -- highest value for upper bound on colormap

function [] = show_CA_List(list,interval,lowerCmapBound,upperCmapBound)

    % bounds on colormap scale
    upper = upperCmapBound;
    lower = lowerCmapBound;
    
    % set default colormap for plots
    %set(groot,'DefaultFigureColormap',jet(64));
    
    % plot the CA gridsshow_CA_List(extgrid_list,10, 23, 27)
    for i = 1:interval:length(list)
        
        % gets data to be plotted
        data = list{i};
           
       % set cmap bounds
       cmax = max(data(:));
       if cmax < upper
           cmax = upper;
       end
       cmin = min(data(:));
       if cmin > lower
           cmin = lower;
       end
       
       % plot the image
       imagesc(data);
       caxis([cmin cmax]);
       colorbar;
       title(sprintf('Frame: %d',i));
       hold;
       axis equal;
       axis tight;
       axis xy;
       
       % wait to go to next image
       fprintf('Wating for any key to be pressed\n');
       w = waitforbuttonpress;
end