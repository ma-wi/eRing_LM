clear all;

static = 0; % 1= static; 0 = dynamic
if (static == 1)
    efs = importdata('data/raw/efs_s21.dat');
else
    efs = importdata('data/raw/efs_d21.dat');
end

nTrainPerGes = 5; % number of training examples for each gesture
nEx = 50; % total number of examples for each gesture
nGes =  6; % number of gestures
nTestPerGes = nEx - nTrainPerGes; % number of test examples for each gesture
nTotal = nGes * nEx; % total number of examples
nTest = (nEx - nTrainPerGes) * nGes; % total number of test examples
nTrain = nTotal - nTest;

if (static == 1)
    pNum = 70; % number of interpolation points
else
    pNum = 65; % number of interpolation points
end

% copy time data (and let start time line at 0)
t = efs(:,1)-efs(1,1);

% labels (the button state must be inverted (0=pressed; 1=released)
l = (~efs(:,3)) .* efs(:,2);

% data
d = efs(:, 4:7);

% -2 indicates a direct touch on the electrode; so we can set it to a big value
d(d == -2) = max(max(d));

nd = size(d, 1);

% plot data
plot(t, l*10000, t, d(:,1), t, d(:,2), t, d(:,3), t, d(:,4));



% initialize the new data cells and vectors
exTmp = cell(nTotal, 1);
labelTmp = zeros(nTotal, 1);
exTmp2 = cell(nTotal, 1);
labelTmp2 = zeros(nTotal, 1);
eTest = cell(nTest, 1);
eTestLabel = zeros(nTest, 1);
eTrain = cell(nTrain, 1);
eTrainLabel = zeros(nTrain, 1);
data = cell(nTotal, 1);
labels = zeros(nTotal, 1);

lastLabel = 0;
count = 1;
maxLen = 0;
for n = 1:nd % for each data point in d
    
    if (l(n) ~= 0) % active label (n>0)
        if (lastLabel == 0) % label changed from 0 to n>0
            dtmp = d(n,:)';
            ttmp = t(n);
            lastLabel = l(n);
        elseif (lastLabel == l(n)) % add data until the label does not change
            dtmp = [dtmp,  d(n,:)'];
            ttmp = [ttmp, t(n)];
        end
    elseif (lastLabel ~= 0) % no label (l(n)=0) => gesture finished
        
        % workaround for too short gestures
        if (length(ttmp) == 1)
            ttmp = [t(n-2), ttmp, t(n)];
            dtmp = [d(n-2,:)', dtmp, d(n, :)'];
        end
        
        if (size(dtmp, 2) > maxLen)
            maxLen = size(dtmp,2);
        end
        
        % create new time axis (for interpolation needed)
        for i = 2:length(ttmp)
            if (ttmp(i) == ttmp(i-1))
                ttmp(i) = ttmp(i) + 1;
            elseif (ttmp(i-1) > ttmp(i))
                ttmp(i) = ttmp(i) + (abs(ttmp(i-1) - ttmp(i)) + 1);
            end
        end
        ttmp = ttmp - ttmp(1);
        xp = linspace(0, ttmp(end), pNum);
        % interpolate
        dtmp2 = zeros(4, pNum);
        for i = 1:4
            dtmp2(i, :) = interp1(ttmp, dtmp(i, :), xp);
        end
        
        exTmp{count} = dtmp2;
        labelTmp(count) = lastLabel;
        count = count + 1;
        
        lastLabel = 0;
    end
    
end

% create an additional data set with a randomized order
% and copy data
rndIdx = randperm(nTotal);
for n = 1:nTotal
    if (static == 1)
    data{n} = exTmp{n};
    else 
        data{n} = zscore(exTmp{n}, 0, 2);
    end
    labels(n) = labelTmp(n);
    exTmp2{n} = exTmp{rndIdx(n)};
    labelTmp2(n) = labelTmp(rndIdx(n));
end

% copy data in a proper structure
sdata = cell(nGes, nEx);
nec = ones(nGes, 1);
for n = 1:length(labels)
    sdata{labels(n), nec(labels(n))} = data{n};
    nec(labels(n)) = nec(labels(n)) + 1;
end

% create a training and test set
ceTest = zeros(nGes, 1);
countTest = 1;
countTrain = 1;

for n = 1:nTotal % for each example in exTmp
    
    % save data
    if (ceTest(labelTmp2(n)) >= nTestPerGes) % save test data
        
        if (static == 0)
            eTrain{countTrain} = zscore(exTmp2{n}, 0, 2);
        else
            eTrain{countTrain} = exTmp2{n};
        end
        eTrainLabel(countTrain) = labelTmp2(n);
        countTrain = countTrain + 1;
        
    else % save training data
        
        if (static == 0)
            eTest{countTest} = zscore(exTmp2{n}, 0, 2);
        else
            eTest{countTest} = exTmp2{n};
        end
        eTestLabel(countTest) = labelTmp2(n);
        ceTest(labelTmp2(n)) =  ceTest(labelTmp2(n)) + 1;
        countTest = countTest + 1;
        
    end
end

maxLen

% data: all data in a structure [nTotal x 1]
% labels: associated labels for data
% sdata: all data in a structue [nGes x nEx]
% rndIdx: randomized index vector of data
% eTest: test set created from randomized data order
% eTestLabel: associated labels
% eTrain: training set created from randomized data order
% eTrainLabel: associated labels
if (static == 1)
    save data/efs_s_data.mat eTest eTrain eTrainLabel eTestLabel rndIdx labels data sdata
else
    save data/efs_d_data.mat eTest eTrain eTrainLabel eTestLabel rndIdx labels data sdata
end

