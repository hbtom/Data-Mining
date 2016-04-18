clc;
close all;
clear;

load('raw_data.mat','Datac_all','Datac_train','Datac_test','Evaluatec');

%%
% test
% Datac_train = Datac_train(1:300,:);

m = 5;
[r_Datac_train,c_Datac_train] = size(Datac_train);
[r_Datac_test,c_Datac_test] = size(Datac_test);
t_map = cell(m,1);
for i = 1:c_Datac_train-1
    t_max = max(Datac_train(:,i));
    t_min = min(Datac_train(:,i));
    for t = 1:m
        t_map{t,1}(1,1) = t_min + (t_max - t_min) * (t-1)/5;
        t_map{t,1}(1,2) = t_min + (t_max - t_min) * t/5;
    end;
    for j = 1:r_Datac_train
        for t = 1:m
            if Datac_train(j,i) >= t_map{t,1}(1,1) && Datac_train(j,i) <= t_map{t,1}(1,2)
                Datac_train(j,i) = t;
            end;
        end;
    end
end;

for i = 1:c_Datac_test-1
    t_max = max(Datac_test(:,i));
    t_min = min(Datac_test(:,i));
    for t = 1:m
        t_map{t,1}(1,1) = t_min + (t_max - t_min) * (t-1)/5;
        t_map{t,1}(1,2) = t_min + (t_max - t_min) * t/5;
    end;
    for j = 1:r_Datac_test
        for t = 1:m
            if Datac_test(j,i) >= t_map{t,1}(1,1) && Datac_test(j,i) <= t_map{t,1}(1,2)
                Datac_test(j,i) = t;
            end;
        end;
    end
end;
save('DT_data.mat','Datac_train','Datac_test','Evaluatec');

