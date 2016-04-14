clear;
clc;
close all;
% load('epinion_trust_with_timestamp.mat');
load('rating_with_timestamp.mat');
user_item = rating(1:end,[1,2,4]);


user_item(1:end,3) = (user_item(1:end,3) - 1) / (5 - 1);
r_user_item = length(user_item);
rand_indices = randperm(r_user_item);
train_percent = 0.8;
m = length(user_item);
train_set = user_item(rand_indices(1,1:m*train_percent),:);
test_set = user_item(rand_indices(1,m*train_percent:end),:);

%%
%
%  ²úÉúRÓëtest_set,train_set
%
user_index = unique(user_item(1:end,1));
item_index = unique(user_item(1:end,2));
r_user_index = length(user_index);
r_item_index = length(item_index);
R = zeros(r_user_index,r_item_index);
r_train_set = size(train_set,1);
r_test_set = size(test_set,1);

for i = 1:r_train_set
    tic;
    user_id = train_set(i,1);
    temp_user_index = find(user_index == user_id,1);
    item_id = train_set(i,2);
    temp_item_index = find(item_index == item_id,1);
    train_set(i,1) = temp_user_index;
    train_set(i,2) = temp_item_index;
    R(temp_user_index,temp_item_index) = train_set(i,3);
    toc;
end;

for i =1: r_test_set
    tic;
    user_id = test_set(i,1);
    temp_user_index = find(user_index == user_id,1);
    item_id = test_set(i,2);
    temp_item_index = find(item_index == item_id,1);
    test_set(i,1) = temp_user_index;
    test_set(i,2) = temp_item_index;
    toc;
end;
R = sparse(R);

save('data.mat','R','train_set','test_set');
