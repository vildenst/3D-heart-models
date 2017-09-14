function displayWithScar(no, withEpi)

global SEG
localSEG = SEG{no};

figure
hold on
title(['Checking final result on subject ' int2str(no)]);

% Plot endo points
plot3(localSEG.EndoPoints.Frame{1}(:,1),localSEG.EndoPoints.Frame{1}(:,2),...
    localSEG.EndoPoints.Frame{1}(:,3),'r.')
plot3(localSEG.EpiPoints.Frame{1}(:,1),localSEG.EpiPoints.Frame{1}(:,2),...
    localSEG.EpiPoints.Frame{1}(:,3),'g.')

% Plot epi points if necessary
if withEpi
    plot3(localSEG.RVEndoPoints.Frame{1}(:,1),localSEG.RVEndoPoints.Frame{1}(:,2),...
        localSEG.RVEndoPoints.Frame{1}(:,3), '.','Color', [0.5 0 0.5])
    plot3(localSEG.RVEpiPoints.Frame{1}(:,1),localSEG.RVEpiPoints.Frame{1}(:,2),...
        localSEG.RVEpiPoints.Frame{1}(:,3),'c.')
end

% Plot scar points
plot3(localSEG.ScarMhd(:,1),localSEG.ScarMhd(:,2),localSEG.ScarMhd(:,3),'.',...
    'Color',[1, 0.8, 0])
hold off