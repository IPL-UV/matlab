function groups = folds(n, vf)

% function groups = folds(n, vf)
%
% Creates the vf groups for a length n

s = rand('state');
rand('state',0);
groups = ceil(vf*randperm(n)/n);
rand('state',s);
