function fig2eps(fname)

% close all
% d = dir('*.fig');

% for i = 1:length(d)
   
    open(fname);
    pname = strrep(fname, '.fig', '.eps');
    print('-depsc2', pname);
    
    close
    
% end
