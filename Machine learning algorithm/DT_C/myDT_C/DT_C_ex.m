clc;
clear;
close all;

load('data.mat','train_set','test_set');
[r_train_set,c_train_set] = size(train_set);
[r_test_set,c_test_set] = size(test_set);
epsion = 0;
X = train_set(1:end,1:c_train_set-1);
y = train_set(1:end,c_train_set);
feature = [1:1:c_train_set-1];
% tree = ID3_C(X,y,epsion,feature);
tree = CART_C(X,y,epsion,feature);
% tree = C4_5_C(X,y,epsion,feature);
y_predict = DT_C_predict(tree,test_set);

