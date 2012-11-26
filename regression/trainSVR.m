function [model,bestSigmaValue] = trainSVR(X,Y)

% function model = trainSVR(X,Y)

vf    = 4;
eps   = [0.001 0.01 0.1:0.1:0.5];
C     = logspace(0,3,10);

% Automatic sigma for the people
md = L2_distance(X',X');
md = mean(md(:));
mins = floor(log10(md/10));
maxs = ceil(log10(md*10));
sigma = logspace(mins, maxs, 10);

% gamma = 1./(2*sigma.*sigma);

bestEps = 1;
bestC = 1;
bestSigma = 1;
bestMse = Inf;

for ss = 1:numel(sigma)
    
    K = kernelmatrix('rbf', X', X', sigma(ss));
    
    for cc = 1:numel(C)
        
        for ee = 1:numel(eps)
            
            %params = sprintf('-s 3 -t 2 -g %f -c %f -p %f -v %d', gamma(ss), C(cc), eps(ee), vf);
            params = sprintf('-s 3 -t 4 -c %f -p %f -v %d', C(cc), eps(ee), vf);
            mse = svmtrain(Y,K,params);
            if mse < bestMse
                bestMse = mse;
                bestEps = ee;
                bestC   = cc;
                bestSigma = ss;
            end
            
        end        
    end
end

% params = sprintf('-s 3 -t 2 -g %f -c %f -p %f', gamma(bestSigma), C(bestC), eps(bestEps));
K = kernelmatrix('rbf', X', X', sigma(bestSigma));
params = sprintf('-s 3 -t 4 -c %f -p %f', C(bestC), eps(bestEps));
model = svmtrain(Y,K,params);
bestSigmaValue = sigma(bestSigma);
