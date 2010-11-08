function [ct,cv] = getsets(YY, classes, percent, vfold, randstate)

% function [ct,cv] = getsets(YY, classes, percent, vfold, [randstate])
% This funcion return a train set (ct) and a validation set (cv) among the
% classes 'classes' of vector 'YY'. 'percent' is the length percentage of
% the 'cv' set, and the optional argument 'randstate' sets the state of the
% random generator (by default = 0). If 'vfold' is nonzero, then a cross
% validation method is to be used and we just make sets with all the samples.
%
% By JoRdI 2006-07.

if nargin < 5
    randstate = 0;
end

s = rand('state');
rand('state',randstate);
ct = []; cv = [];
for ii=1:length(classes)
    idt = find(YY == classes(ii));
    if vfold
        ct = union(ct,idt);
        cv = ct;
    else
        lt  = fix(length(idt)*percent);
        idt = idt(randperm(length(idt)));
        %idv = idt(1:end-lt);  % remove cue
        idv = idt(lt+1:end); % remove head
        idt = setdiff(idt,idv);
        ct  = union(ct,idt);
        cv  = union(cv,idv);
    end
end
rand('state',s);
