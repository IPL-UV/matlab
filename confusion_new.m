%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Matlab function: confusion_new.m
%
% DESCRIPTION: A confusion matrix is created based on
% a clustering result. 
%
% OUTPUT
%
% INPUT
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [errors,err_cl,confusion,confusion_perc,index,OA,Kappa]=confusion_new(labels,true_labels); 
  
  % Number of true clusters
  C = max(true_labels);
  
  % Para cada clase busca los indices de las muestras de esa clase
  for i = 1 : C;
    f_i = find(true_labels == i);
    size_f_i = length(f_i);
    
    % Busca la clase asignada en las etiquetas predecidas para los indices de una clase de las muestras true 
    for j = 1 : C;
      f_j = find(labels(f_i) == j);
      confusion(i,j) = length(f_j);
      
      confusion_perc(i,j) = length(f_j) / size_f_i;
    end;
    
  end;

[maximal,index]=sort(confusion_perc,2,'descend');
clok=unique(index(:,1)); %clases que existen en index
poscl=setdiff(1:C,clok); %clases que no estan en index y hay qe asignar

[val,indrep]=repvector(index(:,1));% vemos donde y que clases se repiten

clrep=unique(val);% clases que se repiten
b=[];
for p=1:length(clrep)
    indclrep=find(index(:,1)==clrep(p));% buscamos los indices en index para una clase que se repite 
    [maxi,ind]=max(maximal(indclrep)); % buscamos el max entre los valores de los indices que se repiten
    b = [b;setdiff(indclrep,indclrep(ind))];% vector con los indices de index que aun no tienen clase
end
while ~isempty(b) % Si esta vacio todas las clases estan asignadas
    %Se genera la CM con las filas de clases repetidas y con las columnas
    %de las posibles clases y buscamos el max de esa matriz
    [v,ind]=max(confusion(b,poscl),[],2);
    
    if length(unique(ind))==length(poscl);%Si no se repiten los indices del maximo
        index(b,1)=poscl(ind);% asignamos cada posible clase a cada ind repetido
        b=[];
    else %Si se repiten los indices del maximo puede ser porque los valores en la matriz sean iguales o no
        [v1,i]=repvector(v);
        if isempty(v1) %Si los valores de la matriz son diferentes para cada ind repetido
            [val,in]=sort(v,'descend'); %ordenamos los valores y obtenemos los correspondientes ind
            index(b(in))=poscl(in);% asignamos cada posible clase a cada ind repetido ya ordenado
            b=[]; %No quedan indices sin clase
        elseif length(unique(v1))==1 % Si todos los valores de la matriz son iguales
            index(b)=poscl;%Asignamos cada clase posible sin importarnos el orden
            b=[];%No quedan indices sin clase
        else %Puede ser que se repitan algunos ind pero no otros
            [v,i]=repvector(ind);%Buscamos los que se repiten
            index(b(ind(setdiff(1:length(ind),i))),1)=poscl(ind(setdiff(1:length(ind),i)));%Asignamos la clase que le toca a los indices que no se repiten
            b = setdiff(b,b(ind(setdiff(1:length(ind),i))));% Eliminamos de b el indice que se le ha asignado la clase
            poscl=setdiff(poscl,poscl(ind(setdiff(1:length(ind),i))));%eliminamos de la clase el valor asignado
        end
    end
end
    
index=index(:,1)';

  for k = 1 : C;
%     confusion_k = confusion(:,k);
% confusion_k = confusion(k,:);
%     confusion_k_perc = confusion_perc(:,k);
% confusion_k_perc = confusion_perc(k,:);


%     err(k) = sum(confusion_k) - confusion_k(index(1));
err(k) =  sum(confusion(k,:))-confusion(k,index(k));
  end
  err_cl=err./sum(confusion');
  errors = sum(err);
  errors= errors/sum(sum(confusion));
  confusion=confusion(:,index);
  
  
  % Compute Overall Accuracy and Cohen's kappa statistic
  n      = sum(confusion(:));                     % Total number of samples
  PA     = sum(diag(confusion));
  OA     = PA/n;
  
  % Estimated Overall Cohen's Kappa (suboptimal implementation)
  npj = sum(confusion,1);
  nip = sum(confusion,2);
  PE  = npj*nip;
  if (n*PA-PE) == 0 && (n^2-PE) == 0
      % Solve indetermination
      warning('0 divided by 0')
      Kappa = 1;
  else
      Kappa  = (n*PA-PE)/(n^2-PE);
  end
  
    
  
  
  
  
  
  
  
  
  
  