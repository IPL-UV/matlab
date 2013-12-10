%
% ESTIMATESIGMA This function estimates reasonable sigma values for the RBF kernel using different methods.
%
%    sigma = estimateSigma(X,Y,method)
%
%    INPUTS:
%       X      : data matrix: n samples, d features: n x d
%       Y      : labels for data, n x 1 (optional)
%       method :
%
%         ---unsupervised approaches, call: estimateSigma(X,[],method)
%
%          1:  'mean' ................... Average distance between all samples
%          2:  'median' ................. Median of the distances between all samples
%          3:  'quantiles' .............. 10 values to try in the range of 0.05-0.95
%                                         percentiles of the distances between all samples
%          4:  'histo' .................. Sigma proportional to the dimensionality and feature variance
%          5:  'range' .................. 10 values to try in the range of 0.2-0.5 of the feature range
%          6:  'silverman' .............. Median of the Silverman's rule per feature
%          7:  'scott' .................. Median of the Scott's rule per feature
%          8:  'maxlike' ................ Maximum likelihood estimate (with standard cross-validation)
%          9:  'bayes' .................. Maximum Bayes estimate (with standard cross-validation)
%         10:  'entropy' ................ Maximum Entropy estimate (with standard cross-validation)
%         11:  'ksdens' ................. Average estimate of univariate/marginal kernel density estimates
%         12:  'kde' .................... KDE using Gaussian kernel
%                                       (http://www.ics.uci.edu/~ihler/code/kde.html is needed)
%
%         ---supervised approaches, call: estimateSigma(X,Y,method)
%
%         13:  'alignment' .............. Kernel alignment (i.e. HSIC maximization between data and labels)
%         14:  'krr' .................... Kernel ridge regression
%
%    OUTPUTS:
%       sigma  : the estimated sigmas in a Matlab structure
%       cost   : the estimated CPU time for computing the corresponding sigma
%
% Gustavo Camps-Valls, 2013
% gustavo.camps@uv.es, http://isp.uv.es
%

function [sigma cost] = estimateSigma(X,Y,method)

% Subsampling
[n d] = size(X);
idx = randperm(n);
if n>1000
    n = 1000;
    X = X(idx(1:n),:);
    if ~isempty(Y)
        Y = Y(idx(1:n),:);
    end
end

% Range of sigmas
ss = 20;
SIGMAS = logspace(-3,3,ss);

if sum(strcmpi(method,'mean'))
    t=cputime;
    D = pdist(X);
    sigma.mean = mean(D(D>0));
    cost.mean = cputime-t;
end

if sum(strcmpi(method,'median'))
    t=cputime;
    D = pdist(X);
    sigma.median = median(D(D>0));
    cost.median = cputime-t;
end

if sum(strcmpi(method,'quantiles'))
    t=cputime;
    D = pdist(X);
    sigma.quantiles =  quantile(D(D>0),linspace(0.05,0.95,10));
    cost.quantiles = cputime-t;
end

if sum(strcmpi(method,'histo'))
    t=cputime;
    sigma.sampling = sqrt(d)*median(var(X));
    cost.sampling = cputime-t;
end

if sum(strcmpi(method,'range'))
    t=cputime;
    mm = minmax(X');
    sigma.range = median(mm(:,2)-mm(:,1))*linspace(0.2,0.5,10);
    cost.range = cputime-t;
end

if sum(strcmpi(method,'silverman'))
    t=cputime;
    sigma.silverman = median( ((4/(d+2))^(1/(d+4))) * n^(-1/(d+4)).*std(X,1) );
    cost.silverman = cputime-t;
end

if sum(strcmpi(method,'scott'))
    t=cputime;
    sigma.scott = median( diag( n^(-1/(d+4))*cov(X).^(1/2) ));
    cost.scott = cputime-t;
end

if sum(strcmpi(method,'maxlike'))
    t=cputime;
    mle = zeros(1,ss);
    r = randperm(n);
    ntrain = round(n*0.9);
    X1 = X(r(1:ntrain),:)';
    X2 = X(r(ntrain+1:end),:)';
    n1sq = sum(X1.^2);
    n1 = size(X1,2);
    n2sq = sum(X2.^2,1);
    n2 = size(X2,2);
    D = (ones(n2,1)*n1sq)' + ones(n1,1)*n2sq -2*X1'*X2;
    for i = 1:ss
        s = SIGMAS(i);
        K = (1/(s*sqrt(2*pi)))*exp(-D/(2*s^2));
        mle(i) = sum(log(sum(K)./size(K,2)));
    end
    [~, idx] = max(mle);
    sigma.maxlike = SIGMAS(idx);
    cost.maxlike = cputime-t;
end

if sum(strcmpi(method,'bayes'))
    t=cputime;
    bayes = zeros(1,ss);
    r = randperm(n);
    ntrain = round(n*0.9);
    X1 = X(r(1:ntrain),:)';
    X2 = X(r(ntrain+1:end),:)';
    n1sq = sum(X1.^2);
    n1 = size(X1,2);
    n2sq = sum(X2.^2,1);
    n2 = size(X2,2);
    D = (ones(n2,1)*n1sq)' + ones(n1,1)*n2sq -2*X1'*X2;
    for i = 1:ss
        s = SIGMAS(i);
        K = (1/(s*sqrt(2*pi)))*exp(-D/(2*s^2));
        bayes(i) = sum(log(sum(K)./size(K,2)))+log(1./SIGMAS(i));
    end
    [~, idx] = max(bayes);
    sigma.bayes = SIGMAS(idx);
    cost.bayes = cputime-t;
end

if sum(strcmpi(method,'entropy'))
    t=cputime;
    entropy = zeros(1,ss);
    r = randperm(n);
    ntrain = round(n*0.9);
    X1 = X(r(1:ntrain),:)';
    X2 = X(r(ntrain+1:end),:)';
    n1sq = sum(X1.^2);
    n1 = size(X1,2);
    n2sq = sum(X2.^2,1);
    n2 = size(X2,2);
    D = (ones(n2,1)*n1sq)' + ones(n1,1)*n2sq -2*X1'*X2;
    for i = 1:ss
        s = SIGMAS(i);
        K = (1/(s*sqrt(2*pi)))*exp(-D/(2*s^2));
        entropy(i) = sum(K(:));
    end
    [~, idx] = max(entropy);
    sigma.entropy = SIGMAS(idx);
    cost.entropy = cputime-t;
end

if sum(strcmpi(method,'ksdens'))
    t=cputime;
    estim = zeros(1,d);
    for i=1:size(X,2)
        [~,~,estim(i)]= ksdensity(X(:,i));
    end
    sigma.ksdensity = mean(estim);
    cost.ksdensity = cputime-t;
end

if sum(strcmpi(method,'kde'))
    t=cputime;
    px = kde(X','lcv');
    s  = getBW(px);
    sigma.kde = unique(s);
    cost.kde = cputime-t;
end

if sum(strcmpi(method,'alignment')) && ~isempty(Y)
    t=cputime;   
    H = eye(n) - 1/n*ones(n,n);
    Ky = Y*Y';
    ka = zeros(1,ss);
    SIGMAS = logspace(-3,3,ss);
    for i=1:ss
        s = SIGMAS(i);
        Kx = kernelmatrix('rbf',X',X',s);
        ka(i) = trace(H*Kx*H*Ky);
    end
    [~, idx] = max(ka);
    sigma.alignment = SIGMAS(idx);
    cost.alignment = cputime-t;  
end

if sum(strcmpi(method,'krr')) && ~isempty(Y)
    t=cputime;   
    r = randperm(n);
    ntrain = round(n*0.9);
    X1 = X(r(1:ntrain),:);    X2 = X(r(ntrain+1:end),:);
    Y1 = Y(r(1:ntrain),:);    Y2 = Y(r(ntrain+1:end),:);
    res = zeros(ss*10,3);
    k=0;
    for i=1:ss
        s = SIGMAS(i);
        K = kernelmatrix('rbf',X1',X1',s);
        for g=logspace(-4,4,10)
            k=k+1;
            alpha = (K+g*eye(size(K)))\Y1;
            Ktest = kernelmatrix('rbf',X2',X1',s);
            Yp    = Ktest*alpha;
            res(k,:) = [s g norm(Y2-Yp,'fro')];
        end
    end
    [~, idx] = min(res(:,3));
    sigma.krr = res(idx,1);
    cost.krr = cputime-t;  
end


