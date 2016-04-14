clc;
clear;
close all;
load('data.mat','Datac_all','Datac_train','Datac_test','Evaluatec');
%%
% test
Datac_train = Datac_train(1:300,:);

n = 70;
m = 2;
accuracy = zeros(m,n);
[r_Datac_train,c_Datac_train] = size(Datac_train);
rand_index = randperm(r_Datac_train);

%%
% four-fold cross verification
for i = 1:m
    for k = 1:n
        test_set = Datac_train(rand_index(1,( r_Datac_train * (i-1)/4 +1 ) : r_Datac_train * i/4),:);
        train_set = Datac_train;
        train_set(rand_index(1,( r_Datac_train * (i-1)/4 +1 ) : r_Datac_train * i/4),:) = [];
        accuracy(i,k) = KNN_C(train_set,test_set,k);
    end;
end;

%%
% find the best K and save the result
[M1,I1] = max(accuracy,[],2);
[M2,I2] = max(M1);
sel_k = I1(I2,1);
accuracy_test = KNN_C(Datac_train,Datac_test,sel_k);
save('KNN_C_accuracy.mat','accuracy_test');



    