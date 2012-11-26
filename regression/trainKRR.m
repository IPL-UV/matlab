function model = trainKRR(xt,yt,xv,yv)

% function model = trainKRR(xt,yt,xv,yv)
%
%  xt, yt: training set (samples, labels)
%  xv, yv: validation set
%
%  model: model generated using [xt],[yt]
%
% (c) 2009 JoRdI

% if nargin < 5, debug = 1; end

[samples outdim] = size(yt);

medianSigma = estimateSigma([xt;xv]);
sigmaMin = log(medianSigma*0.5);
sigmaMax = log(medianSigma*2);

sigma = logspace(sigmaMin,sigmaMax,30);
gamma = logspace(-4,4,30);

% sigma = 15.8489;
% gamma = 1e-3;

rmse = Inf;
for ls = 1:numel(sigma)
    %if debug, fprintf('  sigma: %f\n', sigma(ls)); end
    
    Kt = kernelmatrix('rbf', xt', xt', sigma(ls));
    Kv = kernelmatrix('rbf', xv', xt', sigma(ls));
    
    %if debug, fprintf('    gamma:'); end
    for lg = 1:numel(gamma)
        %if debug, fprintf(' %f', gamma(lg)); end
        
        % Train
        % 1/ Slow: compute the inverse of the regularized kernel matrix:
        % alpha = inv(gamma(lg) * eye(size(yt,1)) + Kt) * yt;
        % 2/ Faster: solve the linear problem:
        % alpha = (gamma(lg) * eye(size(yt,1)) + Kt) \ yt;
        % 3/ Even faster: Cholesky decomposition
        R = chol(gamma(lg) * eye(size(yt,1)) + Kt);
        alpha = R\(R'\yt);

        % Validate
        yp = Kv * alpha;
        
        % Validation error
        if outdim > 1
            res = norm(yv-yp,'fro');
        else
            res = mean( sqrt(mean((yv-yp).^2)) );
        end
        if res < rmse
            model.sigma = sigma(ls);
            model.gamma = gamma(lg);
            rmse = res;
        end
    end
    %if debug, fprintf('\n'); end
end

% Final model
model.x = xt;
K = kernelmatrix('rbf', model.x', model.x', model.sigma);
model.alpha = inv(model.gamma * eye(size(yt,1)) + K) * yt;

