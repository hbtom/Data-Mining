function [P,error,U] =  SVD( R,k,gamma,iteration,target_set,target_result)
%R: users x items matrix
%k: the dimension used in singular value decomposition
%gamma: learning rate
%Author: Da-Chuan Zhang
%date: 2015-10-13
%version:1

error = zeros(iteration,1);
res = zeros(iteration,1);
rmin = 0;
rmax = 20;
%km,kn,kc regularization coeffcients
km = 0.01;
kn = 0.01;
kc = 0.01;
%m: the number of users
%n: the number of items
[m,n] = size(R);

U = 0.1*rand(m,k)./sqrt(k);
M = 0.1*rand(n,k)./sqrt(k);

I = R;
I(I > 0) = 1;
alpha = zeros(m,1);
beta = zeros(n,1);
a = sum(sum(R))/sum(sum(I));
P =repmat(a,[m,n]) +  U*M' + repmat(alpha,[1,n]) + repmat(beta',[m,1]);

for t = 1:iteration
    E = 0.5*sum(sum((((R - P).*I).^2)))...
        + km/2*sum(sqrt(sum(U.^2,2)).^2)...
        + kn/2*sum(sqrt(sum(M.^2,2)).^2)...
        + kc/2*(sum(alpha.^2) + sum(beta.^2));
    res(t) = E;
    %update U
    for i = 1:m
        dU = sum(repmat(((R(i,:) - P(i,:)).*I(i,:))',[1,k]).*M) - km*U(i,:);
        U(i,:) = U(i,:) + gamma.*dU;
    end
    %update M
    for j = 1:n
        dM = sum(repmat((R(:,j) - P(:,j)).*I(:,j),[1,k]).*U) - kn*M(j,:);
        M(j,:) = M(j,:) + gamma.*dM;
    end
    %update alpha
    alpha = alpha + gamma.*(sum((R - P).*I,2) - kc.*alpha);
    %update beta
    beta = beta + gamma.*(sum((R - P).*I,1)' - kc.*beta); 
    %update P
    P =repmat(a,[m,n]) +  U*M' + repmat(alpha,[1,n]) + repmat(beta',[m,1]);
    P(P > rmax) = rmax;
    P(P < rmin) = rmin;
    error(t) = test( R,P,target_set,target_result );
end
plot(error);
end

