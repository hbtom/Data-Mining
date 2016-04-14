clc;
clear;
close all;

load('raw_data.mat','Datac_all','Datac_train','Datac_test','Evaluatec');
%%
% % test
% Datac_train = Datac_train(1:100,:);
% Datac_test = Datac_test(1:10,:);
% Evaluatec = Evaluatec(1:10,:);

accuracy = NB_C(Datac_train,Datac_test,Evaluatec);
% accuracy = NB_C_Laplace(Datac_train,Datac_test,Evaluatec);
