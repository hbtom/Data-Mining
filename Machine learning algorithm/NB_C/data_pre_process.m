clc;
clear;
close all;
Datac_all = xlsread('Datac_all.csv');
Datac_train = xlsread('Datac_train.csv');
Datac_test = xlsread('Datac_test.csv');
Evaluatec = xlsread('Evaluatec.xlsx');
Evaluatec = Evaluatec(1:end,1);
[r_Datac_train,c_Datac_train] = size(Datac_train);
[r_Datac_test,cDatac_test] = size(Datac_test);
Datac_test = [Datac_test';zeros(1,r_Datac_test)]';
% Datac_train = (Datac_train - repmat(min(Datac_all),[r_Datac_train,1])) ./ repmat(max(Datac_all) - min(Datac_all),[r_Datac_train,1]);
% Datac_test = (Datac_test - repmat(min(Datac_all),[r_Datac_test,1])) ./ repmat(max(Datac_all) - min(Datac_all),[r_Datac_test,1]);
save('raw_data.mat','Datac_all','Datac_train','Datac_test','Evaluatec');