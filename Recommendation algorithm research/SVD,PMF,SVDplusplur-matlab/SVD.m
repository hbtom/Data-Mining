function [mae,rmse,P] =  SVD( R,test_set,k,gamma,iteration)
%R: users x items matrix
%k: the dimension used in singular value decomposition
%gamma: learning rate
%Author: Da-Chuan Zhang
%date: 2015-10-13
%version:1

mae = zeros(iteration,1);
rmse = zeros(iteration,1);
res = zeros(iteration,1);
% rmin = 0;
% rmax = 5;
%km,kn,kc regularization coeffcients
km = 0.001;
kn = 0.001;
kc = 0.001;
%m: the number of users
%n: the number of items
[m,n] = size(R);
real_rating = test_set(1:end,3);
r_real_rating = size(real_rating,1);

I = R;
I(I > 0) = 1;
implicit_R = I;
alpha = zeros(m,1);
beta = zeros(n,1);
% + repmat(sum(implicit_R,2),[1,k])
% + repmat(sum(implicit_R,1)',[1,k])
U = 0.1*rand(m,k) ;
M = 0.1*rand(n,k) ;
a = sum(sum(R))/sum(sum(I));
P =repmat(a,[m,n]) +  U*M' + repmat(alpha,[1,n]) + repmat(beta',[m,1]);
P = sigmoid(P);

for t = 1:iteration
    tic;
    E = 0.5*sum(sum((((R - P).*I).^2)))...
        + km/2*sum(sqrt(sum(U.^2,2)).^2)...
        + kn/2*sum(sqrt(sum(M.^2,2)).^2)...
        + kc/2*(sum(alpha.^2) + sum(beta.^2));
    res(t) = E;
    %update U
    for i = 1:m
        dg = sigmoid(P(i,:)).*(1-sigmoid(P(i,:)));%sigmoid function derivation
        dU = sum(repmat(((R(i,:) - P(i,:)).*I(i,:).*dg)',[1,k]).*M) - km*U(i,:);
        U(i,:) = U(i,:) + gamma.*dU;
    end
    %update M
    for j = 1:n
        dg = sigmoid(P(:,j)).*(1-sigmoid(P(:,j)));%sigmoid function derivation
        dM = sum(repmat((R(:,j) - P(:,j)).*I(:,j).*dg,[1,k]).*U) - kn*M(j,:);
        M(j,:) = M(j,:) + gamma.*dM;
    end
    %update alpha
    alpha = alpha + gamma.*(sum((R - P).*I,2) - kc.*alpha);
    %update beta
    beta = beta + gamma.*(sum((R - P).*I,1)' - kc.*beta); 
    %update P
    P =repmat(a,[m,n]) +  U*M' + repmat(alpha,[1,n]) + repmat(beta',[m,1]);
    P = sigmoid(P);
    
    predict_rating = zeros(r_real_rating,1);
    for i = 1:r_real_rating
        user_id = test_set(i,1);
        item_id = test_set(i,2);
        predict_rating(i) = P(user_id,item_id);
    end;
    predict_rating = predict_rating * 5;
    mae(t) = t_MAE( predict_rating, real_rating );
    rmse(t) = t_RMSE( predict_rating,real_rating);
    fprintf('Iteration %d,the MAE is %f, the RMSE is %f,and the Error is %f\n',t,mae(t),rmse(t),res(t));
    toc;
end
% plot(error);
end

