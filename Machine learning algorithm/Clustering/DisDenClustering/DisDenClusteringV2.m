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
radiusPerscent =rp;% ռ���ݼ��еİٷּ���ȷ���뾶
c=clusterK;
clusterid = zeros(n,1);



node(1) = 1;
node(2) = n;
layerInfo(1) = 1;%
layerInfo(2) = n;%�Ӿ���������
layerInfo(3) = 0;%��ʾ���Է��� layerInfo(4)= ��׼�� layerInfo(5)=�ܶ� layerInfo(6)= �뾶
layerNode = zeros(node(2),1);
layerNode(1:node(2),1)=(1:node(2));%��ʼ�����ڵ�


%% �㷨�ǵݹ����ʽ

while clusterK > 1
    % clusterK = -1;
    %% calculate radius
    lLayer = node(1);%����Ҫ���з��ѽڵ㣨�ĸ��ڵ�Ҫ�����ѣ�
    lDatasetNum = layerInfo(lLayer,2);%����Ҫ���з��ѽڵ��а�����Ԫ�ظ���
    
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
    layerInfo(lLayer,7) =radius ;%����뾶
    %% calculate density by Gaussian kernel
    density = zeros(n,1);
    for i = 1: lDatasetNum-1
        for j = i+1: lDatasetNum
            density(lLayerNode(i)) = density(lLayerNode(i)) + exp(-(datasetdist(lLayerNode(i),lLayerNode(j))/radius)*(datasetdist(lLayerNode(i),lLayerNode(j))/radius));
            density(lLayerNode(j)) = density(lLayerNode(j)) + exp(-(datasetdist(lLayerNode(i),lLayerNode(j))/radius)*(datasetdist(lLayerNode(i),lLayerNode(j))/radius));
        end
    end
    
    
    [density_sorted, density_position] = sort(density,'descend');%���ܶȽ�������
    
    %% �����������ľ��루�������ܶȱ��Լ����������������ľ��ࣩ
    deltadistance(density_position,1) = -1;% ÿ��������ľ��붼��ʼ��Ϊ-1��
    nearestneigh(density_position,1) = 0; % ��¼�ܶȱ��Լ�������������
    
    for i=2: lDatasetNum
        deltadistance(density_position(i)) = maxpoint;%������������ֵ
        for j=1:i-1
            if(datasetdist(density_position(i),density_position(j))<deltadistance(density_position(i)))
                deltadistance(density_position(i)) = datasetdist(density_position(i),density_position(j));
                nearestneigh(density_position(i)) = density_position(j);
            end
        end
    end
    deltadistance(density_position(1)) = max(deltadistance(:));%��һ����ֵΪ��������һ��ֵ������ڶ����������ĵ�ľ���
    
    %% ��ֵlog(density) * delta
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

    %% ѡ�����ĵ����С�ܶȼ�����
    denthre(1) = density(threshold_position(1));%ǰ�������ĵ��ܶ�
    denthre(2) = density(threshold_position(2));
    deltathre(1)=deltadistance(threshold_position(1));
    deltathre(2)=deltadistance(threshold_position(2));
    densityminx=min(denthre);
    deltaminy=min(deltathre);
    
    %��ʼ��
    centernum = 0;
    cluster = zeros(n,1);% n

    i=1:lDatasetNum;
    cluster(lLayerNode(i))=-1;
    %ɸѡ�����ĵ�
    centercluster = zeros();
    for i=1:lDatasetNum
        if((density(lLayerNode(i)))>=densityminx && deltadistance(lLayerNode(i))>=deltaminy)
            centernum = centernum +1;%���ĵ�����������
            cluster(lLayerNode(i)) = centernum;
            centercluster(centernum) = lLayerNode(i);%��¼���ĵ�λ��
        end
    end

    %% ����
    datasetclusternum = zeros();
    datasetcluster = zeros();
    i=1:centernum;
    datasetclusternum(i) =1;%���������ʼ��Ϊ1
    datasetcluster(i,1) = centercluster(i);
    datasetcluster(i,2:lDatasetNum) = 0;
    
    %assignation ����
    
    for i=1:lDatasetNum
        if(cluster(density_position(i)) == -1)
            cluster(density_position(i)) = cluster(nearestneigh(density_position(i)));%��density_position(i)����ĵ������ڵľ��ำ�����
            datasetclusternum(cluster(density_position(i))) = datasetclusternum(cluster(density_position(i)))+1;
            datasetcluster(cluster(density_position(i)),datasetclusternum(cluster(density_position(i))))=density_position(i);%���䵽��Ӧ�ľ�����
            
        end
    end
    
    %% �쳣��û���޳�
    
    for i =1:centernum
        kk = size(layerInfo,1)+1;%���Ҫ�洢��λ��
        layerInfo(kk,1) = kk;
        subclusternum = datasetclusternum(i);
        layerInfo(kk,2) = subclusternum;%����
        noZeroIndex = datasetcluster(i,:)>0;%�޳�Ϊ0�ĵ㣬�õ�����
        noZeroNode = datasetcluster(i,noZeroIndex);
        layerNode(1:subclusternum,kk) = noZeroNode;%�ѵ����
        %% �����׼��
        distance = zeros();%��¼�þ���ĵ�֮��ľ��룬�������׼��
        k=1;
        for h = 1:subclusternum-1
            for g = h+1:subclusternum;
                if(datasetcluster(i,g) ~= 0 && datasetcluster(i,h) ~=0 && datasetdist(datasetcluster(i,h),datasetcluster(i,g)) ~= 0)
                    distance(k) = datasetdist(datasetcluster(i,h),datasetcluster(i,g));%��׼��
                    k = k+1;
                end
            end
        end
        standardDeviation = std(distance);
        layerInfo(kk,4) =  standardDeviation;
        
        
        %% ����ƽ���ܶ�
        if(subclusternum~=1)
            dataPairDen = subclusternum * (subclusternum-1)/2;
        else
            dataPairDen=subclusternum;
        end
        %subdatasetDis = zeros(dataPairDen ,1);
        k =1;
        subdatasetDis = distance';
        %%����ȷ���뾶
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
        layerInfo(kk,6) =subradius ;%����뾶
    end
    
    layerInfo(lLayer,3) = 1;%��ǵ�ǰ�ڵ��Ѿ����ѹ�
    %% �´�Ҫ���з��ѵĽڵ�
    
    
    indexNext =  layerInfo(:,3) ==0;%�ҵ�Ҷ�ӽڵ㣬�����ٴη��ѵĵ㣬����
    next2Node = layerInfo(indexNext,1);%�ҵ�Ҷ�ӽڵ㣬�����ٴη��ѵĵ㣬
    %%���뷽��+�ܶȷ��� �淶��
    %����ٷֱ�
    ss = sum(layerInfo(next2Node(:,1),4));
    next2Node(:,2) = layerInfo(next2Node(:,1),4)/ss;
    %�ܶȰٷֱ�
    dd = sum(layerInfo(next2Node(:,1),5));
    next2Node(:,3) = layerInfo(next2Node(:,1),5)/dd;
    %���� X �ܶ�
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
