function fig2png(fname)

% close all
% d = dir('*.fig');

% for i = 1:length(d)
   
    open(fname);    
    pname = strrep(fname, '.fig', '.png');
    
    image = get(get(gca,'children'),'cdata');
    cm = colormap;
    if max(image(:)) == 1
        image = image * size(colormap,1);
    else
        if min(image(:)) == 0
            image = image + 1;
        end
        if strfind(pname, 'aviris')
            % Number of colors used in the image
            colors_used = numel(unique(image));
            % Find indexes in color map
            idx = ceil(linspace(1,size(cm,1),colors_used));
            % Take only those colors
            cm = cm(idx,:);
        end
    end
    
    imwrite(image,cm,pname,'png');
    
    %close
    
% end
