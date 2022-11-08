function [x_opt] = FP_Upre_opt(A, b, N)
%The ill posed problem is generated by gravity with n=100
%creation of sampling matrix W_i

A=Psf2Matrix(A);
%questo comando serve solo a trasformare la matrice A da Psf a matrice
%double



n=size(A, 1);
d=size(A, 1)/10;

%creazione matrici di campionamento
for j=1:d
    
    W(:, (j-1)*10+1:j*10)=[zeros(10*(j-1), 10); eye(10); zeros(10*(d-j), 10)];
    
end





%initializing some data
sigma2=2;
%sigma dipende dal livello di sfocatura gaussiana
Lambda_sum=0;
lambda=0;


A_sum=0;
A=double(A);
A_sum_2=0;
l=10; %size of the sampling matrix
x=ones(n, 1);

%array to plot 
X=zeros(1, N);


%permutazione randomica delle matrici di campionamento
W=RandM(W,d);

for i=0:N-1
iterazione=i %solo per controllare le iterazioni
    
    j=mod(i, d)+1;
    
    if(mod(i, d)==0)       %Ciclicamente, ogni 10 it circa permutiamo la matrice W
        W=RandM(W, d);
        
    end
 
    
    %calcolo elementi nella sommatoria
    W_k=W(:,(j-1)*10+1:j*10);
    
    
    A_k=transpose(W_k)*A;
    b_k=transpose(W_k)*b;
    A_sum=A_sum+transpose(A_k)*A_k;
    A_sum_2=A_sum_2+transpose(A_k)*transpose(W_k);
    
    dim=size(A_sum);
    
    %definisco le funzioni C_k e x_k in lambda
    %che mi serviranno per calcolare lambda in U_k
    
    
    C_k=@(y)((y+Lambda_sum)*eye(dim)+A_sum)^(-1)*A_sum_2;
    
    x_k=@(y) C_k(y)*b;
    
    U_k=@(y) norm(A_k*x_k(y)-b_k)^2+2*sigma2*trace(A_k*C_k(y)*W_k)-sigma2*l;
    
    
    %stampo la funzione per qualche iterazione
    %if(i<3)
     % xp=-1:0.01:1;
      %  yp=Plot(xp, U_k);
       % plot(xp, yp);
        %hold on
    %end
    
    
    [lambda_k , ~]=fminbnd(U_k, 0 , 10^(-7), optimset('Display','iter'));
    %molto del risultato finale dipende dal bound, bisogna giocarci un po'
    Lambda_sum=Lambda_sum+lambda_k;
    
    
    
    %ora che ho trovato lambda_k, posso calcolare la k-esima iterazione x_k
    
    x=x_k(0);
    
   
 
    
end



%Y=1:size(X,2);
%figure(1);
%plot(Y, X, '-');
%verificare che x_k tende a x(lambda_sum*10/N)


x_opt=x;
 
end