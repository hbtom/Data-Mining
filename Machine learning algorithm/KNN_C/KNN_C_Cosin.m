function accuracy = KNN_C(Datac_train,Datac_test,k)

[r_Datac_train,c_Datac_train] = size(Datac_train);
[r_Datac_test,c_Datac_test] = size(Datac_test);
Datac_train_feature = Datac_train(1:end,1:c_Datac_train-1);
Datac_train_label = Datac_train(1:end,c_Datac_train);
Datac_test_feature = Datac_test(1:end,1:c_Datac_test-1);
Datac_test_real_label = Datac_test(1:end,c_Datac_test);
Datac_test_predict_label = zeros(r_Datac_test,1);
similarity = zeros(r_Datac_test,r_Datac_train);

%%
% computing similarity using Euclid distance
% for i = 1:r_Datac_test
%     temp1 = repmat(Datac_test_feature(i,1:end),[r_Datac_train,1]);
%     temp1 = temp1 - Datac_train_feature;
%     for j = 1:r_Datac_train
%         similarity(i,j) = sqrt(temp1(j,:) * temp1(j,:)');
%     end;
% end;

%%
% computing similarity using cosin distance

for i = 1:r_Datac_test
    temp1 = Datac_test_feature(i,:);
    temp2 = temp1 * Datac_train_feature';
    temp3 = sqrt(temp1 * temp1') * sqrt(sum(Datac_train_feature .* Datac_train_feature,2))';
    similarity(i,:) = temp2 ./ temp3;
end;

%%
%
% k_similarity = zeros(r_Datac_test,k);
% k_similarity_index = zeros(r_Datac_test,k);
k_similarity_label = zeros(r_Datac_test,k);

for i = 1:r_Datac_test
    [B,I] = sort(similarity(i,:));
    len_B = length(B);
    for j = 1:k
%         k_similarity_index(i,j) = I(len_B-j+1);
        k_similarity_label(i,j) = Datac_train_label(I(len_B-j+1),1);
    end;
end;


k_similarity_label = k_similarity_label + 1;
I1 = k_similarity_label;
I2 = k_similarity_label;
I1(I1 == 2) = 0;
I2(I2 == 1) = 0;
I2(I2 == 2) = 1;
temp2 = [sum(I1,2),sum(I2,2)];
[M,I] = max(temp2');
Datac_test_predict_label = I'-1;
accuracy = mean(double(Datac_test_predict_label == Datac_test_real_label));
fprintf('KNN, K = %d, Test Accuracy: %f\n',k,accuracy);
% accuracy = 0.577

    
    