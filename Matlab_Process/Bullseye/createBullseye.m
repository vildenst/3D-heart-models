function bullseyeChild = createBullseye(data)

%     CREATEBULLSEYE creates a bullseye, with the main function of creating
%     an AHA 17 segment bullseye. Each row in "data" should have the 
%     following structure:
%     
%         [rho1, rho2, nSegs, thetaStart] 
%         
%     where
%     -rho1 is the inner radius
%     -rho2 is the outer radius
%     -nSegs is the number of segments desired per ring
%     -thetaStart is the starting angle of a segment (in degrees)
%     
%     Example: createBullseye([0 0.5 1 0; 0.5 1 4 45; ... 
%                              1 1.5 6 0; 1.5 2 6 0]);
%     This creates the AHA 17-segment bullseye.
% 
% =========================================================================
% Adrian Lam                                                  Oshinski Lab
% August 4 2014                   
% =========================================================================




    sz = size(data);
    ax = gca;
    hold(ax,'on');
    count = 0;
    
    for i = 1:sz(1)
        
        % min number of segments must be at least 1
        if data(i,3) == 0
            data(i,3) = 1;
        end
        
        for j = 1:data(i,3)
            wedgeSize = 360/data(i,3);
            createWedge(j*wedgeSize + data(i,4), ...
                (j+1)*wedgeSize + data(i,4), ...
                data(i,1),data(i,2));
            
            count = count+1;
        end
    end
    
    set(ax,'YTick',[],'XTick',[], ...
        'XLim',[-max(data(:,2))-1 max(data(:,2))+1], ...
        'YLim',[-max(data(:,2))-1 max(data(:,2))+1] ) ;
    
    tmp = findall(gca,'Type','line');
    bullseyeChild = tmp(1:count);
    set(bullseyeChild,'Color','y');
    
end

function [wedgeHandle,XData,YData] = createWedge(theta1,theta2,rho1,rho2)
    
%     CREATEWEDGE creates an unfilled wedge on the polar graph where:
%       -theta1 is the starting angle of the wedge
%       -theta2 is the final angle of the wedge
%       -rho1 is the inner angle of the wedge
%       -rho2 is the outer angle of the wedge
%     
%     Example: createWedge(45,135,3,3.5);
%       
    
    [theta,rho] = getWedgeBorder(theta1,theta2,rho1,rho2);    
    wedgeHandle = polar(gca,theta,rho);
    XData = get(wedgeHandle,'XData');
    YData = get(wedgeHandle,'YData');

end