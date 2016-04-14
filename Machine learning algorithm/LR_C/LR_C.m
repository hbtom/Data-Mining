function [accuracy,theta] = LR_C(train_set,test_set,iteration)

lamda = 0.00002;
accuracy = zeros(1,iteration);
error = zeros(iteration,1);
[r_train_set,c_train_set] = size(train_set);
[r_test_set,c_test_set] = size(test_set);

X = train_set(1:end,1:c_train_set-1);
X = [ones(r_train_set,1) X]';
Y = train_set(1:end,c_train_set);
X_test = test_set(1:end,1:c_test_set-1);
X_test = [ones(r_test_set,1) X_test]';
Y_test_real = test_set(1:end,c_test_set);

theta = rand(c_train_set,1);

for t = 1:iteration
	E = sum(Y' .* log(sigmoid(theta' * X)) + (1-Y)' .* log(1 - sigmoid(theta' * X)));
	error(t) = E;

	dtheta = sum((repmat(Y' - sigmoid(theta' * X),[c_train_set,1]) .* X),2);
	theta = theta + lamda * dtheta;

	Y_test_predict = round(sigmoid((theta' * X_test)'));
	accuracy(t) = mean(double(Y_test_predict == Y_test_real));
	fprintf('LR_C, iteration: %d, cost: %f, accuracy: %f\n',t,error(t,1),accuracy(1,t));
end;

end


