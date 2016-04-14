function t_RMSE = t_RMSE(predict_rating,real_rating)

N = size(real_rating,1);
t_RMSE = sqrt(sum((predict_rating - real_rating) .^2) ./ N);