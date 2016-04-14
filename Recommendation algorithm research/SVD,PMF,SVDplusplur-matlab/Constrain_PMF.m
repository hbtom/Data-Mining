function [P,error,U] =  Constrain_PMF( R,R_test,k,gamma,iteration)
%R: users x items matrix
%k: the dimension used in singular value decomposition
%gamma: learning rate
%Author: Da-Chuan Zhang
%date: 2015-10-13
%version:1

error = zeros(iteration,1);
res = zeros(iteration,1);
% rmin = 0;
% rmax = 5;
%km,kn,kc regularization coeffcients
km = 0.001;
kn = 0.001;
kw = 0.001;
%m: the number of users
%n: the number of items
[m,n] = size(R);

U = 0.1*rand(m,k)./sqrt(k);
M = 0.1*rand(n,k)./sqrt(k);
W = 0.1*rand(n,k)./sqrt(k);
temp = zeros(m,k);

I = R;
I( I > 0 ) = 1;
for i = 1 : m
    for j = 1 : n
        temp(i,:) = temp(i,:) + I(i,j) * W(i,:);
    end;
end;
temp = U + temp ./ repmat(sum(I,2),[1,k]);
P =  temp * M';
P = sigmoid(P);

for t = 1:iteration
    tic;
    E = 0.5*sum(sum((((R - P).*I).^2)))...
        + km/2*sum(sqrt(sum(U.^2,2)).^2)...
        + kn/2*sum(sqrt(sum(M.^2,2)).^2);
    res(t) = E;
    %update U
    for i = 1:m
        dg = sigmoid(P(i,:)).*(1-sigmoid(P(i,:)));
        dU = sum(repmat(((R(i,:) - P(i,:)).*I(i,:).*dg)',[1,k]).*M) - km*U(i,:);
        U(i,:) = U(i,:) + gamma.*dU;
    end
    %update M
    for j = 1:n
        dg = sigmoid(P(:,j)).*(1-sigmoid(P(:,j)));
        dM = sum(repmat((R(:,j) - P(:,j)).*I(:,j).*dg,[1,k]).*temp) - kn*M(j,:);
        M(j,:) = M(j,:) + gamma.*dM;
    end
    %update W
    for l = 1 : n
%         tic;
        dW = zeros(1,k);
        for i = 1 : m
            for j = 1 : n
                dg = sigmoid(temp(i,:) * M(j,:)') * (1-sigmoid(temp(i,:) * M(j,:)'));
                dW = dW + I(i,j) * R(i,j)-P(i,j) * dg * (I(i,l) / sum(I(i,:),2)) * M(j,:);
            end;
        end;
        dW = dW - kw * W(l,:);
        W(l,:) = W(l,:) + gamma.* dW;
%         toc;
    end;
    
    for i = 1 : m
        for j = 1 : n
            temp(i,:) = temp(i,:) + I(i,j) * W(i,:);
        end;
    end;
    temp = U + temp ./ repmat(sum(I,2),[1,k]);
    P =temp * M';
    P = sigmoid(P);
    error(t) = test( R_test,P );
    fprintf('Iteration %d,the MAE is %f,and the Error is %f\n',t,error(t),res(t));
    toc;
end
% plot(error);
end

