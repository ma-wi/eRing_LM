function [smTable, smTablef] = e1Eval()

close all
num = 20;
maxLen = 0;
x = cell(4,num);
y = cell(4,num);

for m = 1:4
    for n = 1:num
        d = importdata(['data/raw/e1/efs_e1_', num2str(m), 'f_', num2str(n-1), '.dat']);
        x{m,n} = d(:,2) - d(1,2);
        y{m,n} = d(:,3+m);
        if (length(y{m,n}) > maxLen)
            maxLen = length(y{m,n});
        end
    end
end

% interpolate data
yp = cell(4, 1);
for m = 1:4
    yp{m} = zeros(num, maxLen);
    for n= 1:num
        
        c = 1;
        mi = -1;
        xn = [];
        yn = [];
        for p = 1:length(x{m,n})
            if (x{m,n}(p) > mi)
                mi = x{m,n}(p);
                xn(c) = x{m,n}(p);
                yn(c) = y{m,n}(p);
                c = c + 1;
            end
        end
        xp = linspace(0, xn(end), maxLen);
        yp{m}(n,:) =  interp1(xn, yn, xp);
    end
end

figure('name', 'Mean of Field Range with Finger inside');
plot(xp, mean(yp{1}), xp, mean(yp{2}), xp, mean(yp{3}), xp, mean(yp{4}));
title('Mean of Field Range of the 4 Sensors with Finger inside');
xlabel('Distance in Pixel');
ylabel('Mean sensor values');
grid on;
print('plots/e1Meanf','-dpng');

figure('name', 'STD of Field Range with Finger inside');
plot(xp, std(yp{1}),xp, std(yp{2}), xp, std(yp{3}), xp, std(yp{4}));
title('Standard Deviation of Field Range the 4 Sensors with Finger inside');
xlabel('Distance in Pixel');
ylabel('Standard deviation of sensor values');
grid on;
print('plots/e1STDf','-dpng');

smTablef = zeros(3, floor(length(xp)/10));
ypm = mean(yp{1});
yps = std(yp{1});
c = 1;
for n = 1:15:length(xp)
    smTablef(1,c) = n/4.5;
    smTablef(2,c) = ypm(n);
    smTablef(3,c) = yps(n);
    c = c + 1;
end
smTablef

for m = 1:4
    figure('name', ['Boxplot of Field Range of sensor ', num2str(m), ' with Finger inside']);
    boxplot(yp{m})
    title(['Boxplot of 20 Field Range Measurements of Sensor ', num2str(m), ' with Finger inside']);
    xlabel('Distance in Pixel');
    ylabel('Sensor values');
    grid on;
    print(['plots/e1BP_', num2str(m), 'f'],'-dpng');
end


%%%
%%% without finger inside the ring
%%%
num = 20;
maxLen = 0;
x = cell(4,num);
y = cell(4,num);

for m = 1:4
    for n = 1:num
        d = importdata(['data/raw/e1/efs_e1_', num2str(m), '_', num2str(n-1), '.dat']);
        x{m,n} = d(:,2) - d(1,2);
        y{m,n} = d(:,3+m);
        if (length(y{m,n}) > maxLen)
            maxLen = length(y{m,n});
        end
    end
end

% interpolate data
yp = cell(4, 1);
for m = 1:4
    yp{m} = zeros(num, maxLen);
    for n= 1:num
        
        c = 1;
        mi = -1;
        xn = [];
        yn = [];
        for p = 1:length(x{m,n})
            if (x{m,n}(p) > mi)
                mi = x{m,n}(p);
                xn(c) = x{m,n}(p);
                yn(c) = y{m,n}(p);
                c = c + 1;
            end
        end
        xp = linspace(0, xn(end), maxLen);
        yp{m}(n,:) =  interp1(xn, yn, xp);
    end
end

figure('name', 'Mean of Field Range');
plot(xp, mean(yp{1}), xp, mean(yp{2}), xp, mean(yp{3}), xp, mean(yp{4}));
title('Mean of Field Range of the 4 Sensors');
xlabel('Distance in Pixel');
ylabel('Mean sensor values');
grid on;
print('plots/e1Mean','-dpng');

figure('name', 'STD of Field Range');
plot(xp, std(yp{1}),xp, std(yp{2}), xp, std(yp{3}), xp, std(yp{4}));
title('Standard Deviation of Field Range the 4 Sensors');
xlabel('Distance in Pixel');
ylabel('Standard deviation of sensor values');
grid on;
print('plots/e1STD','-dpng');

smTable = zeros(3, floor(length(xp)/10));
ypm = mean(yp{1});
yps = std(yp{1});
c = 1;
for n = 1:15:length(xp)
    smTable(1,c) = n/4.5;
    smTable(2,c) = ypm(n);
    smTable(3,c) = yps(n);
    c = c + 1;
end
smTable

for m = 1:4
    figure('name', ['Boxplot of Field Range of sensor ', num2str(m)]);
    boxplot(yp{m})
    title(['Boxplot of 20 Field Range Measurements of Sensor ', num2str(m)]);
    xlabel('Distance in Pixel');
    ylabel('Sensor values');
    grid on;    
    print(['plots/e1BP_', num2str(m)],'-dpng');
end
end