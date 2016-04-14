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
train_data = user_item(rand_indices(1,1:m*train_percent),:);
test_data = user_item(rand_indices(1,m*train_percent:end),:);

%%
%
%  ²úÉúR_trainÓëR_test,user-item-rating matrix
%
user_index = unique(user_item(1:end,1));
item_index = unique(user_item(1:end,2));
r_user_index = length(user_index);
r_item_index = length(item_index);
R_train = zeros(r_user_index,r_item_index);
R_test = zeros(r_user_index,r_item_index);
r_train_data = length(train_data);
r_test_data = length(test_data);

for i = 1:r_train_data
    tic;
    user_id = train_data(i,1);
    temp_user_index = find(user_index == user_id,1);
    artist_id = train_data(i,2);
    temp_item_index = find(item_index == artist_id,1);
    R_train(temp_user_index,temp_item_index) = train_data(i,3);
    toc;
end;

for i =1: r_test_data
    tic;
    user_id = test_data(i,1);
    temp_user_index = find(user_index == user_id,1);
    artist_id = test_data(i,2);
    temp_item_index = find(item_index == artist_id,1);
    R_test(temp_user_index,temp_item_index) = test_data(i,3);
    toc;
end;

save('exercise_data3.mat','R_train','R_test');


