function [Yp,Vp] = testSVR(model,Xtrain,Xtest,sigma)

% function [Yp,Vp] = testSVR(model,X)

% Calculate prediction
Kt = kernelmatrix('rbf',Xtest',Xtrain',sigma);
Yp = svmpredict(zeros(size(Xtest,1),1), Kt, model);

if nargout > 1
    Ktrain = kernelmatrix('rbf',Xtrain',Xtrain',sigma);
    % Add an epsilon to diagonal to ensure positive (yeah, I know Ktrain should be,
    % but precission issues, you know ...)
    Ktrain = Ktrain + eps * eye(size(Xtrain,1));
    R = chol(Ktrain)';
    v = R \ Kt';
    Vp = ones(size(Xtest,1),1) - sum(v.*v)';
end
