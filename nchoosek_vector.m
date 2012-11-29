function A=nchoosek_vector(N,k)

[I,J]=size(N);

if I==1 || J==1 %Vector fila o columna
    for t = 1:max(I,J)
        A(t)=nchoosek(N(t),k);
    end
else %si es mariz
    for i = 1:I
        for j=1:J
            if N(i,j)>k
                A(i,j)=nchoosek(N(i,j),k);
            else
                A(i,j)=0;
            end
        end
    end
end