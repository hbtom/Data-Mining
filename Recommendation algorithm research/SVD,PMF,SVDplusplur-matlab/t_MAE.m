function t_MAE = t_MAE(predict_rating,real_rating)

N = size(real_rating,1);
t_MAE = sum(abs(predict_rating - real_rating)) ./ N;
end

