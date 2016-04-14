function [clusterid]=DisDenClusteringV2(data,clusterK,classid,rp)
%Author: Da-Chuan Zhang
%date: 2015-12-01
% Input:
%       data -- is the kernel matrix.
%       clusterK -- is the number of cluster.

% Output:
%       classid -- is the classid that COLL have learned.
%       ephilist and distortionlist are two internal evaluations for testing the convergence.
%

%% Checking the input
if nargin < 4
    error('stats:TooFewInputs','At least two input arguments required: dataset and the number of clusters');
end

%% My algorithm here
n = size(data,1);% The number of data points.
d = size(data,2);% The dimensions.
datasetdist = L2_distance(data',data');% calculate distance matrix
radiusPerscent =rp;% 占数据集中的百分几来确定半径
c=clusterK;
clusterid = zeros(n,1);



node(1) = 1;
node(2) = n;
layerInfo(1) = 1;%
layerInfo(2) = n;%子聚类对象个数
layerInfo(3) = 0;%表示可以分裂 layerInfo(4)= 标准差 layerInfo(5)=密度 layerInfo(6)= 半径
layerNode = zeros(node(2),1);
layerNode(1:node(2),1)=(1:node(2));%初始化根节点


%% 算法非递归的形式

while clusterK > 1
    % clusterK = -1;
    %% calculate radius
    lLayer = node(1);%现在要进行分裂节点（哪个节点要被分裂）
    lDatasetNum = layerInfo(lLayer,2);%现在要进行分裂节点中包含的元素个数
    
    lLayerNode = layerNode(:,lLayer);
    dataPair = lDatasetNum*(lDatasetNum-1)/2;
    datasetDis = zeros(dataPair,1);
    k = 1;
    
    for i = 1: lDatasetNum-1
        for j = i+1: lDatasetNum
            if(datasetdist(lLayerNode(i),lLayerNode(j)) ~= 0)
                datasetDis(k,1) = datasetdist(lLayerNode(i),lLayerNode(j));
                k = k+1;
            end
        end
    end
    
    % radiusposition1 = round(lDatasetNum*(lDatasetNum-1)*radiusPerscent/100)+(dataPair - k); %
    radiusposition = ceil(dataPair*radiusPerscent/100); %
    radiusada = sort(datasetDis(:,1));
    radius = radiusada(radiusposition);% radius
    maxpoint = max(datasetDis(:,1));
    layerInfo(lLayer,7) =radius ;%保存半径
    %% calculate density by Gaussian kernel
    density = zeros(n,1);
    for i = 1: lDatasetNum-1
        for j = i+1: lDatasetNum
            density(lLayerNode(i)) = density(lLayerNode(i)) + exp(-(datasetdist(lLayerNode(i),lLayerNode(j))/radius)*(datasetdist(lLayerNode(i),lLayerNode(j))/radius));
            density(lLayerNode(j)) = density(lLayerNode(j)) + exp(-(datasetdist(lLayerNode(i),lLayerNode(j))/radius)*(datasetdist(lLayerNode(i),lLayerNode(j))/radius));
        end
    end
    
    
    [density_sorted, density_position] = sort(density,'descend');%对密度进行排序
    
    %% 计算样本点间的距离（条件，密度比自己大中最近的样本点的聚类）
    deltadistance(density_position,1) = -1;% 每个样本点的距离都初始化为-1；
    nearestneigh(density_position,1) = 0; % 记录密度比自己大的最近样本点
    
    for i=2: lDatasetNum
        deltadistance(density_position(i)) = maxpoint;%距离矩阵中最大值
        for j=1:i-1
            if(datasetdist(density_position(i),density_position(j))<deltadistance(density_position(i)))
                deltadistance(density_position(i)) = datasetdist(density_position(i),density_position(j));
                nearestneigh(density_position(i)) = density_position(j);
            end
        end
    end
    deltadistance(density_position(1)) = max(deltadistance(:));%第一个赋值为距离最大的一个值。即与第二个聚类中心点的距离
    
    %% 阈值log(density) * delta
    threshold = zeros(n,1);
    for i=1:lDatasetNum
        % index(i) = i;
        if( density(lLayerNode(i)) == 0 )
            threshold(lLayerNode(i)) = 0;
            clusterid(lLayerNode(i))= c+1;
        else
            threshold(lLayerNode(i)) = log(density(lLayerNode(i))) * deltadistance(lLayerNode(i));
        end
    end
    
    [threshold_sorted, threshold_position]=sort(threshold,'descend');

    %% 选择中心点的最小密度及距离
    denthre(1) = density(threshold_position(1));%前两个中心的密度
    denthre(2) = density(threshold_position(2));
    deltathre(1)=deltadistance(threshold_position(1));
    deltathre(2)=deltadistance(threshold_position(2));
    densityminx=min(denthre);
    deltaminy=min(deltathre);
    
    %初始化
    centernum = 0;
    cluster = zeros(n,1);% n

    i=1:lDatasetNum;
    cluster(lLayerNode(i))=-1;
    %筛选出中心点
    centercluster = zeros();
    for i=1:lDatasetNum
        if((density(lLayerNode(i)))>=densityminx && deltadistance(lLayerNode(i))>=deltaminy)
            centernum = centernum +1;%中心点个数，及标号
            cluster(lLayerNode(i)) = centernum;
            centercluster(centernum) = lLayerNode(i);%记录中心点位置
        end
    end

    %% 分裂
    datasetclusternum = zeros();
    datasetcluster = zeros();
    i=1:centernum;
    datasetclusternum(i) =1;%聚类个数初始化为1
    datasetcluster(i,1) = centercluster(i);
    datasetcluster(i,2:lDatasetNum) = 0;
    
    %assignation 分配
    
    for i=1:lDatasetNum
        if(cluster(density_position(i)) == -1)
            cluster(density_position(i)) = cluster(nearestneigh(density_position(i)));%把density_position(i)最近的点所属于的聚类赋予给它
            datasetclusternum(cluster(density_position(i))) = datasetclusternum(cluster(density_position(i)))+1;
            datasetcluster(cluster(density_position(i)),datasetclusternum(cluster(density_position(i))))=density_position(i);%分配到对应的聚类中
            
        end
    end
    
    %% 异常点没有剔除
    
    for i =1:centernum
        kk = size(layerInfo,1)+1;%获得要存储的位置
        layerInfo(kk,1) = kk;
        subclusternum = datasetclusternum(i);
        layerInfo(kk,2) = subclusternum;%个数
        noZeroIndex = datasetcluster(i,:)>0;%剔除为0的点，得到索引
        noZeroNode = datasetcluster(i,noZeroIndex);
        layerNode(1:subclusternum,kk) = noZeroNode;%把点存入
        %% 计算标准差
        distance = zeros();%记录该聚类的点之间的距离，用来求标准差
        k=1;
        for h = 1:subclusternum-1
            for g = h+1:subclusternum;
                if(datasetcluster(i,g) ~= 0 && datasetcluster(i,h) ~=0 && datasetdist(datasetcluster(i,h),datasetcluster(i,g)) ~= 0)
                    distance(k) = datasetdist(datasetcluster(i,h),datasetcluster(i,g));%标准差
                    k = k+1;
                end
            end
        end
        standardDeviation = std(distance);
        layerInfo(kk,4) =  standardDeviation;
        
        
        %% 计算平均密度
        if(subclusternum~=1)
            dataPairDen = subclusternum * (subclusternum-1)/2;
        else
            dataPairDen=subclusternum;
        end
        %subdatasetDis = zeros(dataPairDen ,1);
        k =1;
        subdatasetDis = distance';
        %%重新确定半径
        subradiusposition = ceil(dataPairDen*radiusPerscent/100); %
        
        subradiusada = sort(subdatasetDis(:,1));
        subradius = subradiusada(subradiusposition);% radius
        %% calculate density by Gaussian kernel
        subdensity = zeros(n,1);
        for l = 1: subclusternum-1
            for j = l+1: subclusternum
                subdensity(noZeroNode(l)) = subdensity(noZeroNode(l)) + exp(-(datasetdist(noZeroNode(l),noZeroNode(j))/subradius)*(datasetdist(noZeroNode(l),noZeroNode(j))/subradius));
                subdensity(noZeroNode(j)) = subdensity(noZeroNode(j)) + exp(-(datasetdist(noZeroNode(l),noZeroNode(j))/subradius)*(datasetdist(noZeroNode(l),noZeroNode(j))/subradius));
            end
        end
        
        densityTemp = subdensity(noZeroNode);
        layerInfo(kk,5)=std(densityTemp);
        layerInfo(kk,6) =subradius ;%保存半径
    end
    
    layerInfo(lLayer,3) = 1;%标记当前节点已经分裂过
    %% 下次要进行分裂的节点
    
    
    indexNext =  layerInfo(:,3) ==0;%找到叶子节点，即可再次分裂的点，索引
    next2Node = layerInfo(indexNext,1);%找到叶子节点，即可再次分裂的点，
    %%距离方差+密度方差 规范化
    %方差百分比
    ss = sum(layerInfo(next2Node(:,1),4));
    next2Node(:,2) = layerInfo(next2Node(:,1),4)/ss;
    %密度百分比
    dd = sum(layerInfo(next2Node(:,1),5));
    next2Node(:,3) = layerInfo(next2Node(:,1),5)/dd;
    %方差 X 密度
    next2Node(:,4) =  next2Node(:,2).*next2Node(:,3);
    [~,Next] = max(next2Node(:,4));
    nextToDivide= next2Node(Next,1);
    
    node(1) = nextToDivide;
    node(2) = layerInfo(nextToDivide,2);
    
    clusterK = clusterK-1;
    
end



ii =1;
clusterid = zeros(n,1);
for i =1:size(layerInfo,1)
    if(layerInfo(i,3) == 0 )
        for j =1:layerInfo(i,2)
            clusterid(layerNode(j,i)) = ii;
        end
        ii=ii+1;
    end
end
