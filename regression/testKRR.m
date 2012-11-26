function [yp vp] = testKRR(model,xp)

% function yp = testKRR(model,xp)
%
%  model: model returned by trainKRR
%  xp:    samples to predict
%
%  yp:    predictions (predictive mean)
%  vp:    predictive variance
%
% (c) 2009 JoRdI,
%     2010 Gus: batch-mode predictions
%     2010 Gus: predictive variances
%

[n d] = size(xp)   % test samples and dimensions
folds = round(n/1000); % number of approximate folds for testing (a fold will contain roughly 1000 samples)
indices = crossvalind('Kfold',1:n,folds); % generate random indices to sample folds

[no do] = size(model.alpha);
yp = zeros(n,do);

% Invert the regularized kernel of training data
if nargout > 1
    Ktt = kernelmatrix('rbf',model.x',model.x',model.sigma) + model.gamma * eye(size(model.x,1));
    Rtt = chol(Ktt)';
end

% Test in folds
for f = 1:folds
    test = find(indices==f);  % select samples belonging to fold "f"
    xtest = xp(test,:);
    Ktest = kernelmatrix('rbf',xtest',model.x',model.sigma);   % test with this fold data only
    % Predictive mean
    yp(test,:) = Ktest * model.alpha;
    % Predictive variance
    if nargout > 1
        v = Rtt \ Ktest';
        vp(test,:) = ones(size(test,1),1) - sum(v.*v)';
    end
end

