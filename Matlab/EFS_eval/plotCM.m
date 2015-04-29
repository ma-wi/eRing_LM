function plotCM()

close all;

figure('name', 'Confusion Matrix for Posture Classification');

load cvresults_static.mat

cm = results{1}.cmTotal/(results{1}.nTest * results{1}.nPartitions/6);

colormap(jet)
imagesc(cm(2:end,2:end))
colorbar
axis('square')
title('Confusion Matrix for Posture Classification')
xlabel('Posture class to be classified')
ylabel('Assinged posture class')

for n = 2:size(cm,2)
    for m = 2:size(cm,1)  
        if (cm(m,n) >= 0.01)
        text(n-1,m-1, num2str(cm(m,n), '%1.2f'), 'FontWeight','Bold','FontSize',20, 'HorizontalAlignment', 'center');
        end
    end
end
print('plots/cm_postures','-dpng')

figure('name', 'Confusion Matrix for Gesture Classification');

load cvresults_dyn.mat

cm = results{1}.cmTotal/(results{1}.nTest * results{1}.nPartitions/6);

colormap(jet)
imagesc(cm(2:end,2:end))
colorbar
axis('square')
title('Confusion Matrix for Gesture Classification')
xlabel('Gesture class to be classified')
ylabel('Assinged gesture class')

for n = 2:size(cm,2)
    for m = 2:size(cm,1)  
        if (cm(m,n) >= 0.01)
        text(n-1,m-1, num2str(cm(m,n), '%1.2f'), 'FontWeight','Bold','FontSize',20, 'HorizontalAlignment', 'center');
        end
    end
end

print('plots/cm_gestures','-dpng')