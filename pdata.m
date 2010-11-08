function pdata(x,y)

% function pdata(x,y)
%
% This function plots the distributions problems

classes = unique(y);

colors = 'rkbygc';

clf, hold on
for i = 1:numel(classes)
    plot(x(y==classes(i),1), x(y==classes(i),2), ['.' colors(mod(i,length(colors)))])
end
hold off


% % +1 labels
% idx1 = find(y == 1);
% % -1 labels
% idx2 = find(y ~= 1);
% % plot
% figure(1)
% plot(x(idx2,1),x(idx2,2),'r.'), hold on
% plot(x(idx1,1),x(idx1,2),'k.'), grid, hold off

% semilogy(x(idx2,1),x(idx2,2),'r.'), hold on
% semilogy(x(idx1,1),x(idx1,2),'kx'), hold off

% figure(2)
% plot3(x(:,1),x(:,2),y,'.'), grid
