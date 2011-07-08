function fig2png(fname)

% close all
% d = dir('*.fig');

% for i = 1:length(d)
   
    open(fname);    
    pname = strrep(fname, '.fig', '.png');
    
    image = get(get(gca,'children'),'cdata');
    cm = colormap;
    
    % Adjust colormap
    if max(image(:)) == 1
        image = image * size(colormap,1);
    else
        % Non-zero index adjustment
        if min(image(:)) == 0
            image = image + 1;
        end

        if strfind(pname, 'aviris')            
            % Number of colors used in the image
            colors = unique(image);
            
            clim = get(gca,'clim');
            
            
            % Specific color maps have consecutive indexes
            %uniqder = unique(diff(colors));
            %if numel(uniqder) == 1 && uniqder(1) == 1
            
            % Specficic colormap
            if clim(2) ~= 16
            
                % Prepare a color map using these specific colors
            
                % Adjust color map, directly or using polyfit
                %m = (1 - size(cm,1)) / (colors(1) - colors(end));
                %p = 1 - m*colors(1);
                %idx = ceil(colors * m + b);
                
                mp = polyfit([colors(1) colors(end)], [1 size(cm,1)], 1);
                idx = round(polyval(mp,colors));
                % Take only those colors
                cm = cm(idx,:);
            else
                % Re-adjust 64 colormap to 16
                cm = cm(1:4:64,:);
            end
        end
    end
    
    imwrite(image,cm,pname,'png');
    
    close
    
% end
