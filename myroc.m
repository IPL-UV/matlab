function [auc,roc] = myroc(yn,dv)

% function [auc,roc] = myroc(yn,dv)
%
% Calculates ROC curve and AUC, assuming we have two classes (+1,-1)
%
%  yn: actual labels
%  dv: model output
%
% Outpus:
%   auc, the area under the curve
%   roc, two columns with TP and FP
%
% The code for the AUC is by Will Dwinell
% (http://will.dwinnell.com/will/SampleError.m)

% Use decision values to compute ROC
hlimit = max(dv);
llimit = min(dv);

% Count observations by class
nTarget  = sum(yn == 1);
nOutlier = sum(yn ~= 1);

if nTarget == 0
    nTarget = 1;
end
if nOutlier == 0
    nOutlier = 1;
end

% Calculate ROC only if requested
if nargout > 1
    roc = zeros(101,2);
    yp  = yn; % reserve memory
    for i = 0:100
        value = i/100 * (hlimit - llimit) + llimit;
        yp(dv >= value) =  1;
        yp(dv <  value) = -1;
        tp = sum(yp(yn == 1) == 1) / nTarget;  % true  positive
        fp = sum(yp(yn ~= 1) == 1) / nOutlier; % false positive
        roc(i+1,:) = [fp tp];
    end
end

% Rank data
R = tiedrank(dv);  % 'tiedrank' from Statistics Toolbox
% Calculate AUC
auc = (sum(R(yn == 1)) - (nTarget^2 + nTarget)/2) / (nTarget * nOutlier);
