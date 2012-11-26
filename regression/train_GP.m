function model = train_GP(X1,Y1)

[Nsamples Nfeatures] = size(X1);

% Define the kernel matrix structure:
% We use a composite kernel accounting for different signal (spectra) and
% noise relations. Specifically, we adopt an RBF kernel for signal
% relations (covSum) with adaptive lengthscale (covSEard), and a diagonal
% noise covariance matrix.

K = {'covSum', {'covSEard','covNoise'}};
% K = {'covSEiso'};

% We have now specified the functional form of the covariance -the kernel- function
% but we still need to specify values of the parameters of these
% covariance functions. In our case we have 3 parameters (also sometimes
% called hyperparameters):
%  - width for the RBF kernel
%  - a signal scaling factor for the kernel
%  - standard deviation of the noise. The logarithm
% of these parameters are specified

% We will model weights by maximizing the marginal likelihood instead of
% doing a free parameters tuning, as this is very expensive with our
% superflexible kernel.

[loghyper fvals iter] = minimize([zeros(Nfeatures,1); 0;log(sqrt(0.2))], 'gpr', -100, K, X1, Y1);
% [loghyper fvals iter] = minimize([0.1 ; 0], 'gpr', -100, K, X1, Y1);

model.loghyper = loghyper;
model.fvals = fvals;
model.iter = iter;
model.K = K;
