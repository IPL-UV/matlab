function image2p(im,percent)

% function image2p(im,percent)
%
% Representa equalizada una imagen RGB
%
% im:      imagen 3 bandas RGB, entre 0-255
% percent: recorte para hacer el stretching del histograma, defecto 2%

if nargin < 2
    percent = 0.02;
end

% A ver si sale el truco del 2%
[rows,cols,bands] = size(im);

% Equalizamos bandas al 2%
% figure(2)
h = hist(reshape(im,rows*cols,bands),0:255);
[b1 mn mx] = eq_band(im(:,:,1),h(:,1),percent);
% subplot(311),plot(0:255,hist(b1(:),0:255)), title([num2str(mn) ' ' num2str(mx)])
ax = axis; axis([0 255 ax(3) ax(4)]);
[b2 mn mx] = eq_band(im(:,:,2),h(:,2),percent);
% subplot(312),plot(0:255,hist(b2(:),0:255)), title([num2str(mn) ' ' num2str(mx)])
ax = axis; axis([0 255 ax(3) ax(4)]);
[b3 mn mx] = eq_band(im(:,:,3),h(:,3),percent);
% subplot(313),plot(0:255,hist(b3(:),0:255)), title([num2str(mn) ' ' num2str(mx)])
ax = axis; axis([0 255 ax(3) ax(4)]);

% Recontruimos
ime = reshape([b1 b2 b3], rows, cols, bands);

% figure(1),imagesc(ime/255)
imagesc(ime/255);

function [b mini maxi] = eq_band(b,h,percent)

% h = hist(b(:),0:255);
if 0
    % Esta opcion no funciona tan bien porque se traga piquitos en los
    % extremos. Se puede arreglar saltándose los extremos, pero es cutre la
    % solución.
    
    % Eliminamos datos por debajo del 2% del maximo
    th = max(h) * percent;
    h = h - th;
    h(h < 0) = 0;
    % primer valor del histograma que supera el 2%
    mini = find(h,1,'first');
    % ultimo valor
    maxi = 256 - find(h(end:-1:1),1,'first');
else
    % Esto es lo que parece que hace el ENVI: elimina el 2% de muestras del
    % histograma por arriba y por abajo.
    
    % Eliminamos 2% de las muestras por arriba y por abajo del histograma
    th = sum(h) * percent;
    ssum = cumsum(h);
    mini = find(ssum > th,1,'first');
    ssum = cumsum(h(end:-1:1));
    maxi = 256 - find(ssum > th,1,'first');
end

% nos cargamos los pixels por debajo y por encima
b(b < mini) = mini;
b(b > maxi) = maxi;

% rescalamos
b = (b-mini)/(maxi-mini) * 255;
