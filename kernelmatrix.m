% function K = kernelmatrix(ker,X,X2,sigma,b,d)
%
% Inputs:
%	ker:    'lin','poly','rbf','sam'
%	X:	data matrix with training samples in rows and features in columns
%	X2:	data matrix with test samples in rows and features in columns
%	sigma: width of the RBF kernel
% 	b:     bias in the linear and polinomial kernel
%	d:     degree in the polynomial kernel
%
% Output:
%	K: kernel matrix

% With Fast Computation of the RBF kernel matrix
% To speed up the computation, we exploit a decomposition of the Euclidean distance (norm)
%
% Gustavo Camps-Valls, 2006
% Jordi (jordi@uv.es),
%   2014-11: added (missing) b,d input parameters. Faster RBF kernel :-).
%   2007-11: if/then -> switch, and fixed RBF kernel
%   2010-04: RBF can be computed now also on vectors with only one feature (ie: scalars)

function K = kernelmatrix(ker,X,X2,sigma,b,d)

switch ker
    case 'lin'
        if exist('X2','var')
            K = X' * X2;
        else
            K = X' * X;
        end
        
    case 'poly'
        if exist('X2','var')
            K = (X' * X2 + b).^d;
        else
            K = (X' * X + b).^d;
        end
        
    case 'rbf'
        n1sq = sum(X.^2,1);
        n1 = size(X,2);
        
        if exist('X2','var');
            n2sq = sum(X2.^2,1);
            n2 = size(X2,2);
            D = n1sq'*ones(1,n2) + ones(n1,1)*n2sq - 2*(X'*X2);
            % In MATLAB, multipliying times 'ones' is faster than repmat!
            % D = repmat(n1sq',1,n2) + repmat(n2sq,n1,1) - 2*(X'*X2);
        else
            D = 2 * (ones(n1,1)*n1sq - X'*X);
            % D = 2 * (repmat(n1s1,n1,1) - X'*X);
        end
        K = exp(-D/(2*sigma^2));
        
    case 'sam'
        if exist('X2','var');
            D = X'*X2;
        else
            D = X'*X;
        end
        K = exp(-acos(D).^2/(2*sigma^2));
        
    otherwise
        error(['Unsupported kernel ' ker])
end
