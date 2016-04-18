clc;
clear;
close all;

load('DT_data.mat','Datac_train','Datac_test','Evaluatec');

%%
% test
% Datac_train = Datac_train(1:300,:);

[r_Datac_train,c_Datac_train] = size(Datac_train);
[r_Datac_test,c_Datac_test] = size(Datac_test);
X = Datac_train(1:end,1:c_Datac_train-1);
y = Datac_train(1:end,c_Datac_train);
feature = [1:1:c_Datac_train-1];
% tree = ID3_C(X,y,0,feature);
tree = CART_C(X,y,0,feature);
% tree = C4_5_C(X,y,0,feature);
Datac_test = Datac_test(:,1:c_Datac_test-1);
y_predict = DT_C_predict(tree,Datac_test);
accuracy_test = mean(double(y_predict == Evaluatec));

