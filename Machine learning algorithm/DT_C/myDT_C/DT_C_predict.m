function y_predict = DT_C_predict(tree,X)

[r_X,c_X] = size(X);
y_predict = zeros(r_X,1);

for i = 1:r_X
    temp_tree = tree;
	while temp_tree.leaf == 0
		feature = temp_tree.attribute(1,1);
		feature_value = temp_tree.attribute(1,2);
		if feature_value == X(i,feature)
			temp_tree = temp_tree.left;
		else
			temp_tree = temp_tree.right;
        end;
    end;
	y_predict(i) = temp_tree.result;
end;

end