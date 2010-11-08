function svmplot(xt,model,sigma,line_style,line_width)

% function svmplot(xt,model,sigma,line_style,line_width)
%
%   plots a 2-D SVM function **over a previous plot**
%
%   xt: training samples
%   model: svm model
%   sigma: sigma used to compute the kernel matrix
%   line_style: optional line style, default 'k:'
%   line_width: optional line width, default 1
%
% TODO:
%   - Properly handle internal/external kernels on libsvm
%   - Improve the contour graph

if nargin < 5
    line_width = 1;
end
if nargin < 4
    line_style = 'k:';
end

Samples    = xt;
Bias       = model.rho;
% SVs        = model.SVs';
SVs        = Samples(model.idx,:); % for precomputed kernels
Parameters = model.Parameters;
% AlphaY     = model.sv_coef; % this can be used to compute the function
                              % directly instead of using svmpredict

input = zeros(size(Samples,1),1);
% Features to paint
xaxis = 1;
yaxis = 2;

% Leave the axis as is
xy = axis;
xmin = xy(1); xmax = xy(2);
ymin = xy(3); ymax = xy(4);
set(gca,'XLim',[xmin xmax],'YLim',[ymin ymax]);  

% Plot function value

[x,y] = meshgrid(xmin:(xmax-xmin)/50:xmax,ymin:(ymax-ymin)/50:ymax); 

z = Bias*ones(size(x));
Inputs = input*ones(1,size(x,2));

fakey = ones(size(Inputs(1,:)))';
for x1 = 1 : size(x,1)
   Inputs(xaxis,:) = x(x1,:);
   Inputs(yaxis,:) = y(x1,:);
   Kin = kernelmatrix('rbf', Inputs([xaxis yaxis],:), xt', sigma);
   [OutLabels, ac, z(x1,:)] = svmpredict(fakey, Kin, model);
   %[OutLabels, ac, z(x1,:)] = svmpredict(fakey, Inputs', model);
end

% Plot Training points

hold on

% Support vectors
plot(SVs(:,1),SVs(:,2),'bo');

% Plot Boundary contour
hold on
contour(x,y,z,[0,0],line_style,'LineWidth',line_width);
if (Parameters(2) ~= 2)
    contour(x,y,z,[1 1],line_style);
    contour(x,y,z,[-1 -1],line_style);
end
hold off
