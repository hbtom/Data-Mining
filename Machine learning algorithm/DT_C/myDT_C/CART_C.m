function [tree] = CART_C(X,y,threshold,feature)

tree = struct('leaf',false,'attribute','null','left','null','right','null','result','null');

r_X = size(X,1);
c_X = size(X,2);

labels = unique(y);
l_labels = length(labels);
%�ݹ���ֹ����
if l_labels == 1
    tree.leaf = true;
    tree.result = y(1);
    return;
end;
%�ݹ���ֹ����
if size(unique(X,'rows'),1) == 1
    tree.leaf = true;
    tree.result = mode(y);
    return;
end;
%�� HD
label_count = zeros(l_labels,1);
for i = 1:r_X
    label_index = find(labels==y(i));
    label_count(label_index) = label_count(label_index) + 1;
end;
HD = -1 * sum((label_count/r_X) .*(log(label_count/r_X)));

D1_index = cell(c_X,1);
D2_index = cell(c_X,1);
Ag = cell(c_X,1);
% GiniD1 = cell(c_X,1);
% GiniD2 = cell(c_X,1);
GiniDA = cell(c_X,1);
%����ָ�� GiniDA
for i = 1:c_X
    D_label = unique(X(1:end,i));
    l_D_label = length(D_label);
    for j = 1:l_D_label
        GiniD1 = 0;
        GiniD2 = 0;
        Ag{i,1}(1,j) = D_label(j);
        D1_index{i,:} = (find(X(1:end,i) == D_label(j)))';
        D1_y = y(D1_index{i,:},1);
        D1_label_count = zeros(l_labels,1);
        l_D1_y = length(D1_y);
        for k = 1:l_D1_y
            D1_label_index = find(labels == D1_y(k));
            D1_label_count(D1_label_index) = D1_label_count(D1_label_index) + 1;
        end;     
        D1_label_count(D1_label_count==0)=[];
        if l_D1_y ~= 0 
            GiniD1 = 1 - sum((D1_label_count/l_D1_y) .^2);
        end;
        D2_index{i,:} = setdiff([1:1:r_X],D1_index{i,:});
        D2_y = y(D2_index{i,:},1);
        D2_label_count = zeros(l_labels,1);
        l_D2_y = length(D2_y);
        for k = 1:l_D2_y
            D2_label_index = find(labels == D2_y(k));
            D2_label_count(D2_label_index) = D2_label_count(D2_label_index) + 1;
        end;
        D2_label_count(D2_label_count == 0)=[];
        if l_D2_y ~= 0    
            GiniD2 = 1 - sum((D2_label_count/l_D2_y) .^2);
        end;
        GiniDA{i,1}(1,j) = (l_D1_y / r_X) * GiniD1 + (l_D2_y / r_X) * GiniD2;
%         fprintf('C4_5_C: Attribute: (%d %d) Information gain ratio %f\n',i,D_label(j),GiniDA{i,1}(1,j));
    end;
%     fprintf('\n');
end;
M2 = [];
I2 = [];
for i = 1:c_X
    [M1,I1] = min(GiniDA{i,1},[],2);
    M2 = [M2,M1];
    I2 = [I2,I1];
end;
[M3,I3] = min(M2);
if M3 < threshold
    tree.leaf = true;
    tree.result = mode(y);
    return;
end;

tree.attribute = [feature(1,I3),Ag{I3,1}(1,I2(1,I3))];
left_X_index = find(X(1:end,I3) == Ag{I3,1}(1,I2(1,I3)));
%ȥ��Ag ����A-{Ag};
% feature = [1:1:c_X];
% feature(feature == I3) = [];
left_X = X(left_X_index,feature);
left_y = y(left_X_index,:);
right_X_index = setdiff([1:1:r_X],left_X_index);
right_X = X(right_X_index,feature);
right_y = y(right_X_index,:);
%�ݹ����
tree.left = CART_C(left_X,left_y,0,feature);
tree.right = CART_C(right_X,right_y,0,feature);