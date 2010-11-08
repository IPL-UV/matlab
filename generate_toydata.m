function [X,Y]=generate_toydata(n,method)

% [X,Y]=generate_toydata(n,method)
%
% Generates toy classification problems.
%
% INPUTS:
%    n     : points in class +1 and n points in class 2
%    method:
%       'lines'          : Parallel lines
%       'ellipsoids'     : Parallel ellipsoids
%       'moons'          : Two moons
%       'swiss'          : 2d swiss roll 
%
% Gustavo Camps-Valls, 2007(c)
% gcamps@uv.es
%
% mod by jordi@uv.es

switch method
    case 'lines'
        %var = 1;
        x = 0.015;
        y = 0.015;
        X1=[randn(n,1)*0.01+x       randn(n,1)*0.01+y];
        Y1=ones(n,1);
        X2=[randn(n,1)*0.01-x       randn(n,1)*0.01-y];
        Y2=2*ones(n,1);
        X=[X1;X2];
        Y=[Y1;Y2];
        
    case 'ellipsoids'
		%mean1 = [-1;0];
		%mean2 = [1.2;05];
		mean1 = [-0.2;-0.2];
		mean2 = [1;0];
		cov = [1 .9; .9 1];
		
		X1 = mvnrnd(mean1,cov,n_points);
		X2 = mvnrnd(mean2,cov,n_points);
		
		X = [X1;X2];
		X = X - ones(2*n_points,1)*mean(X);
		Y = zeros(2*n_points,1); 
        Y(1:n_points,1) = 1; 
        Y(n_points+1:end,1) = 2;
        
    case 'moons'
        space=1;
        noise = 0.05;
        r=randn(n,1)*noise+1;
        theta=randn(n,1)*pi;
        r1=1.1*r; r2=r;
        X1=([r1.*cos(theta) abs(r2.*sin(theta))]);
        Y1=ones(n,1);

        r=randn(n,1)*noise+1;
        theta=randn(n,1)*pi+2*pi;
        r1=1.1*r; r2=r;
        X2=([r1.*cos(theta)+space*rand -abs(r2.*sin(theta)) + 0.5 ]);
        Y2=2*ones(n,1);

        X=[X1;X2];
        Y=[Y1;Y2];
        
    case 'swiss'
        %GENERATE SAMPLED DATA 1
        tt = (3*pi/2)*(1+2*rand(1,n));  %height = 21*randn(1,N);
        X1 = [tt.*cos(tt); tt.*sin(tt)]';

        % GENERATE SAMPLED DATA 2
        tt = (3*pi/2)*(1+2*rand(1,n));  %height = 21*randn(1,N);
        X2 = [tt.*cos(tt);  tt.*sin(tt)]'; X2=1.6*X2;
        X=[X1;X2]/25+randn(2*n,2)*0.03;
        Y=[ones(n,1); 2*ones(n,1)];

    otherwise
        error('Unknown method')
end
