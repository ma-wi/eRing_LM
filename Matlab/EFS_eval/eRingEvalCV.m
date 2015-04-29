function eRingEvalCV

%     if (matlabpool('size') == 0)
%         matlabpool open 8
%     end

clear all

static = 0;

if (static ==1)
    load 'data/efs_s_data.mat';
else
    load 'data/efs_d_data.mat';
end

pSizes = [5]; % numbers of training example for each class per partiation per run
nEx = 50; % number of training example for each class
nGes = 6; % number of classes

% // 0 ="Noise"
% // 1 = "Open"
% // 2 = "Closed"
% // 3 = "Two"
% // 4 = "Index"
% // 5 = "Ring"
% // 6 = "Grasp"

% // 1/7 = "Wish"
% // 2/8 = "Circle"
% // 3/9 = "Square"
% // 4/10 = "Pinch"
% // 5/11 = "Snap"
% // 6/12 = "Drop"

np = length(pSizes);
results = cell(np, 1);

for r = 1:np
    
    totalPart = floor(nEx/pSizes(r)); % total number of partitions
    nTest = (nEx - pSizes(r)) * nGes; % total number of test examples
    
    results{r}.confMat = cell(totalPart, 1);
    results{r}.corLabs = cell(totalPart, 1);
    results{r}.corrects = zeros(totalPart, 1);
    results{r}.errorRates = zeros(totalPart, 1);
    results{r}.cmTotal = zeros(length(unique(labels))+1, length(unique(labels))+1);
    results{r}.cmTotal(:,1) = 0:length(unique(labels));
    results{r}.cmTotal(1,:) = 0:length(unique(labels));
    results{r}.pSize = pSizes(r);
    results{r}.nTest = nTest;
    results{r}.nPartitions = totalPart;
    
    crun = 0;
    prun = 1;
    for p = 1:pSizes(r):nEx % for each partition
        
        
        if (prun <= totalPart)
            
            % copy training data
            trainData = cell(nGes * pSizes(r), 1);
            trainLabels = zeros(nGes * pSizes(r), 1);
            count = 1;
            for m = 1:nGes
                for n = p:(pSizes(r)*prun)
                    trainData{count} = sdata{m, n};
                    trainLabels(count) = m;
                    count = count + 1;
                end
            end
            % copy test data
            testData = cell((nEx - pSizes(r)) * nGes, 1);
            testLabels = zeros((nEx - pSizes(r)) * nGes, 1);
            count = 1;
            for m = 1:nGes
                for n = 1:nEx
                    if ((n<p) || (n > (prun*pSizes(r))))
                        testData{count} = sdata{m, n};
                        testLabels(count) = m;
                        count = count + 1;
                    end
                end
            end
            
            cl = zeros(length(unique(labels)), 2);
            cm = zeros(length(unique(labels))+1, length(unique(labels))+1);
            cl(:,1) = 1:length(unique(labels));
            cm(:,1) = 0:length(unique(labels));
            cm(1,:) = 0:length(unique(labels));
            correct = 0;
            
            for n = 1 : nTest % run test for partition p
                
                py = oneNN(trainData, trainLabels, testData{n});
                if py == testLabels(n)
                    correct = correct + 1;
                    cl(labels(n),2) = cl(labels(n), 2) + 1;
                    disp(['partition ', int2str(r) , ' of ', int2str(np), ': run ', int2str(prun), ' of ', int2str(totalPart), ': ', int2str(n), ' out of ', int2str(nTest), ' done. Label ', int2str(testLabels(n)), ' was correctly classified']);
                else
                    disp(['partition ', int2str(r), ' of ', int2str(np), ': run ', int2str(prun), ' of ', int2str(totalPart), ': ', int2str(n), ' out of ', int2str(nTest), ' done. Label ', int2str(testLabels(n)), ' was NOT correctly classified. Result: ', int2str(py)]);
                end;
                cm(py+1, testLabels(n)+1) = cm(py+1, testLabels(n)+1) + 1;
                results{r}.cmTotal(py+1, testLabels(n)+1) = results{r}.cmTotal(py+1, testLabels(n)+1) + 1;
                crun = crun + 1;
            end
            
            results{r}.corrects(prun) = correct;
            results{r}.errorRates(prun) = (nTest - correct) / nTest;
            results{r}.corLabs{prun} = cl;
            results{r}.confMat{prun} = cm;
            
            prun = prun + 1;
            
        end
    end
    
    disp(['The dataset you tested has ', int2str(length(unique(labels))), ' classes'])
    disp(['The test set is of size ',int2str(size(labels,1)),'.'])
    disp(['The time series are of length ', int2str(size(data{1}(1,:),2))])
    disp(['The total error rate was ',num2str(mean(results{r}.errorRates))])
    
    results{r}.cmTotal
    
end

if (static == 1)
    save cvresults_static.mat results
else
    save cvresults_dyn.mat results
end

end


function [py] = oneNN(X, Lx, y)

bsf = inf;

for i = 1 : length(Lx)
    x = X{i};
    d = LTW(x,y);
    if d < bsf
        py = Lx(i);
        bsf = d;
    end
end
end

function d = LTW(x, y)

w = size(x, 2);
n = size(x, 2);
m = size(y, 2);

d = sum((x(:,1)-y(:,1)).^2);


j = 1;
i = 1;

while (i <= n) && (j <= m)
    
    dij = inf;
    dj = inf;
    di = inf;
    
    if (i+1 <= n) && (j+1 <= m)
        dij = sum((x(:,i+1)-y(:,j+1)).^2);
    end
    if (i+1 <= n) && (abs(i+1-j) <= w)
        di = sum((x(:,i+1)-y(:,j)).^2);
    end
    if (j+1 <= n) && (abs(j+1-i) <= w)
        dj = sum((x(:,i)-y(:,j+1)).^2);
    end
    [dmin, idx] = min([dij, di, dj]);
    if(isinf(dmin))
        break;
    else
        d = d + dmin;
    end
    
    if idx == 1
        i = i + 1;
        j = j + 1;
    elseif idx == 2
        i = i + 1;
    else
        j = j + 1;
    end
    
end
end

function d = DTW(x,y)

w = 100;
m = length(x);
n = length(y);
M = Inf(m+1,n+1);
M(1,1) = 0;

for i = 1:m
    for j = max(1,i-w):min(n,i+w)
        COSTij = sum((x(:,i)-y(:,j)).^2);
        M(i+1,j+1) = COSTij + min([M(i,j+1),M(i+1,j),M(i,j)]);
    end
end
d = M(end,end);
end
