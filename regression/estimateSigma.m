function sigma = estimateSigma(X)

samples = size(X,1);

% Take a maximum of 1000 (randomly selected) points to compute the median distance
if samples>1000
  rand('seed',1234);
  r = randperm(samples);
  Xmed    = X(r(1:1000),:);
  samples = 1000;
else
  Xmed = X;
end

G = sum((Xmed.*Xmed),2);
Q = repmat(G,1,samples);
R = repmat(G',samples,1);
dists = Q + R - 2*Xmed*Xmed';
dists = dists-tril(dists);
dists = reshape(dists,samples^2,1);
sigma = sqrt(0.5*median(dists(dists>0)));

