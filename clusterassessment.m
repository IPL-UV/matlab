function RES=clusterassessment(Ytrue,Ypred)
% funcion que obtiene un struct con indices de validacion de los clustering. 
%
% Input: -Ytrue: etiquetas verdaderas
%        -Ypred: etiquetas predecidas
%
% Output:
%        -E: Entropy, proporciona una medida de bondad del clustering.
%        -P: Purity.
%        -F: F-mesure, combina los conceptos de precision y recall.
%        -VI: Variation of information, cantidad de informacion que se
%        pierde o se gana al cambiar desde un conjunto de datos al conjunto
%        de clusters.
%        -MI: Mutual information, cantidad de informacion que una variable
%        al azar predice de otra.
%        -R: Rand statistic, J: Jaccard coeff, FM: Fowlkes and Mallows
%        index, gamma1: Hubert statistic 1 and gamma2: Hubert statistic 2,
%        evaluan la calidad del clustering mediante acuerdo o desacuerdo de
%        los pares de datos en diferentes particiones.
%        -MS: Minkowski score, mide la diferencia entre los resultados del
%        clustering y los datos de referencia (Ytrue).
%        -VD: van Dongen criterion, mide la representatividad de la mayoria
%        de los objetos en cada clase y en cada cluster.
%        -GK: Goodman-Kruskal coeff and M: Mirkin metric.
%
% 


% for i=1:length(unique(Ytrue))
%     for j=1:length(unique(Ypred))
%         ContingencyMatrix(i,j)=length(find(Ytrue==i & Ypred==j));
%     end
% end


% MATRIZ DE CONFUSION Y ERROR
[err,err_cl,CM,CMprob,indCL,OA,Kappa]=confusion_new(Ypred,Ytrue);


nj = sum(CM,1);
ni = sum(CM,2);
n = sum(CM(:));

pj = nj/n;
pi = ni/n;
pij = CM/n;

% Medidas de validacion
% ENTROPY
for i = 1:length(pi)
    B(i)=pi(i)*sum(pij(i,:)./pi(i).*log(pij(i,:)./pi(i)));
end
% B=pi.*nansum(pij./pi.*log(pij./pi));
% ENTROPY: [0,log(length(unique(Ytrue))] a menor medida mejor clustering
E = -sum(B);

clear B
% PURITY 
for i = 1:length(pi)
    B(i)=pi(i)*max(pij(i,:)./pi(i));
end

% PURITY: (0,1] a mayor medida mejor clustering
P = sum(B);

clear B
% F-MESURE
for j = 1:length(pj)
    for i = 1:length(pi)
        A(i)=2*pij(i,j)/pi(i)*pij(i,j)/pj(j)/((pij(i,j)/pi(i))+(pij(i,j)/pj(j)));
    end
    B(j)=pj(j)*max(A);
end

% F-MESURE: (0,1] a mayor medida mejor clustering
F = sum(B);

% VARIATION OF INFORMATION (VI): [0,2*log(max(length(unique(Ypred),length(unique(Ytrue)))))] a menor medida mejor clustering
A=pij.*log(pij./(pi*pj));
VI = -sum(pi.*log(pi))-sum(pj.*log(pj))-2*sum(A(:));

% MUTUAL INFORMATION (MI): (0,log(length(unique(Ytrue))] a mayor medida mejor clustering
MI = sum(A(:));

% RAND STATISTIC (R): (0,1] a mayor medida mejor clustering
R = (nchoosek(n,2)-sum(nchoosek_vector(ni,2))-sum(nchoosek_vector(nj,2))+2*sum(sum(nchoosek_vector(CM,2))))/nchoosek(n,2);

% JACCARD COEFFICIENT(J): [0,1] a mayor medida mejor clustering
J = sum(sum(nchoosek_vector(CM,2)))/(sum(nchoosek_vector(ni,2))+sum(nchoosek_vector(nj,2))-...
    sum(sum(nchoosek_vector(CM,2))));

% FOWLKES AND MALLOWS INDEX (FM): [0,1] a mayor medida mejor clustering
FM = sum(sum(nchoosek_vector(CM,2)))/sqrt(sum(nchoosek_vector(ni,2))*sum(nchoosek_vector(nj,2)));

% HUBERT GAMMA STATISTIC 1 (Gamma1): (-1,1] a mayor medida mejor clustering
Gamma1 = (nchoosek(n,2)*sum(sum(nchoosek_vector(CM,2)))-sum(nchoosek_vector(ni,2))*sum(nchoosek_vector(nj,2)))/...
sqrt(sum(nchoosek_vector(ni,2))*sum(nchoosek_vector(nj,2))*(nchoosek(n,2)-sum(nchoosek_vector(ni,2)))*(nchoosek(n,2)*sum(nchoosek_vector(nj,2))));

% HUBERT GAMMA STATISTIC 2 (Gamma2): : [0,1] a mayor medida mejor clustering
Gamma2 = (nchoosek(n,2)-2*sum(nchoosek_vector(ni,2))-2*sum(nchoosek_vector(nj,2))+4*sum(sum(nchoosek_vector(CM,2))))/nchoosek(n,2);

% MINKOWSKI SCORE (MS): [0,+inf) a menor medida mejor clustering
MS = sqrt(sum(nchoosek_vector(ni,2))+sum(nchoosek_vector(nj,2))-2*sum(sum(nchoosek_vector(CM,2))))...
    /sqrt(sum(nchoosek_vector(nj,2)));

% VAN DONGEN CRITERIO (VD): [0,1) a menor medida mejor clustering
VD = (2*n-sum(max(CM,[],2))-sum(max(CM)))/(2*n);

clear A
% GOODMAN-KRUSKAL COEFFICIENT (GK): [0,1) a menor medida mejor clustering
for i = 1:length(pi)
    A(i,:)=max(pij(i,:)./pi(i));
end
GK = sum(pi.*(1-A));

% MIRKIN METRIC (M): [0,2*nchoosek_vector(n,2)) a menor medida mejor clustering
M = sum(ni.^2)+sum(nj.^2)-2*sum(sum(CM.^2));


RES.E  = E;
RES.P  = P;
RES.F  = F;
RES.VI = VI;
RES.MI = MI;
RES.R  = R;
RES.J  = J;
RES.FM = FM;
RES.Gamma1 = Gamma1;
RES.Gamma2 = Gamma2;
RES.MS = MS;
RES.VD = VD;
RES.GK = GK;
RES.M  = M;
RES.err=err;
RES.errcl=err_cl;
RES.CM=CM;
RES.CMprob=CMprob;
RES.indCL=indCL;
RES.OA=OA*100;
RES.Kappa=Kappa;
