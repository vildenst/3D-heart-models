function cords = displaySEGandSCAR(SEG)
%  3D plot of both RV & LV, epi & endo segmentations.

sizen=size(SEG.EndoX);
K=sizen(1,1);
S=sizen(1,3);

SliceThickness = SEG.SliceThickness;

% LEG or T1 imaging implies only one time frame.
% n = 1;

% RV
RVEpiX = SEG.RVEpiX(:);
RVEpiY = SEG.RVEpiY(:);

RVEndoX = SEG.RVEndoX(:);
RVEndoY = SEG.RVEndoY(:);

% LV
EpiX = SEG.EpiX(:);
EpiY = SEG.EpiY(:);

EndoX = SEG.EndoX(:);
EndoY = SEG.EndoY(:);

Z = ((1:S)'*SliceThickness*ones(1,K))';

figure;

title('segmentation view')
hold on

% Plot RV and LV, coloring kept as for segmentation
plot3(EpiX, EpiY, Z(:), '-g');
plot3(EndoX, EndoY, Z(:), '-r');
plot3(RVEpiX, RVEpiY, Z(:), '-c');
plot3(RVEndoX, RVEndoY, Z(:), '-m');


% Find and plot scar pixels

for s=1:S
    [X_scar, Y_scar] = find(SEG.Scar.Result(:, :, s));
    if sum(size(X_scar)) > 2
        Z_scar = ones(size(X_scar))*SliceThickness*s;
        plot3(X_scar, Y_scar, Z_scar, '*y');
    end
end
xlabel('X axis');
ylabel('Y_axis');

set(gca,'ZDir','Reverse')
view(180, 30);
print('3Dview','-depsc2','-r300');
hold off

end

