clc;
clear;
close all;
load('data.mat','Datac_all','Datac_train','Datac_test','Evaluatec');

%%
% test
% Datac_train = Datac_train(1:300,:);

m = 4;
iteration = 800;
accuracy = zeros(m,iteration);
[r_Datac_train,c_Datac_train] = size(Datac_train);
[r_Datac_test,c_Datac_test] = size(Datac_test);
rand_index = randperm(r_Datac_train);
theta = zeros(m,c_Datac_train);

%%
% four time cross verification
for i = 1:m
	test_set = Datac_train(rand_index(1,( r_Datac_train * (i-1)/4 +1 ) : r_Datac_train * i/4),:);
    train_set = Datac_train;
    train_set(rand_index(1,( r_Datac_train * (i-1)/4 +1 ) : r_Datac_train * i/4),:) = [];
    [accuracy(i,:),theta(i,:)] = LR_C(train_set,test_set,iteration);
end;

%%
% using the test_set to test
[M,I] = max(max(accuracy,[],2));
Y_test_predict = round(sigmoid((theta(I,:) * [ones(r_Datac_test,1) Datac_test(1:end,1:c_Datac_test-1)]')'));
accuracy_test = mean(double(Y_test_predict == Evaluatec));


