function accuracy = NB_C(train_set,test_set,Y_test_real)

[r_train_set,c_train_set] = size(train_set);
[r_test_set,c_test_set] = size(test_set);
X = train_set(1:end,1:c_train_set-1);
Y = train_set(1:end,c_test_set);
X_test = test_set(1:end,1:c_test_set-1);
% Y_test_predict = zeros(r_test_set,1);
X(X>1) = 1;
X_test(X_test>1) = 1;

index_0 = find(~Y);
index_1 = find(Y);
X_0 = X(index_0,:);
X_1 = X(index_1,:);

Pxy = zeros(r_test_set,2);
Pc0 = sum(length(index_0)) / r_train_set;
Pc1 = sum(length(index_1)) / r_train_set;
for i = 1:r_test_set
	temp1 = sum(~xor(repmat(X_test(i,:),[length(index_0),1]),X_0));
	px_c0 = temp1 / length(index_0);
	temp2 = sum(~xor(repmat(X_test(i,:),[length(index_1),1]),X_1));
	px_c1 = temp2 / length(index_1);
	Pxy(i,1) = Pc0 * prod(px_c0);
	Pxy(i,2) = Pc1 * prod(px_c1);
end;
[M,I ] = max(Pxy,[],2);
Y_test_predict = I-1;
accuracy = mean(double(Y_test_predict == Y_test_real));
fprintf('NB_C, accuracy: %f\n', accuracy);
