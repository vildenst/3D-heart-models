function [theta_wedge,rho_wedge] = getWedgeBorder(theta1,theta2,rho1,rho2)
 
%     GETWEDGEBORDER returns theta/rho vectors of the wedge border
%     coordinates that can be plotted using "polar" where:
%     
%     -theta1/2 is the starting/final angle of the wedge in degrees.
%     -rho1/2 is the inner/outer radius of the wedge
%     -theta_wedge is the theta coordinates for the wedge
%     -rho_wedge is the radius coordinates for the wedge.      
% 
%     Example: [theta,rho] = getWedgeBorder(45,135,1.5,2);
%     polar(theta,rho)
% 
% =========================================================================
% Adrian Lam                                                  Oshinski Lab
% August 4 2014                   
% =========================================================================
    
    % Check to make sure a wedge of 360deg comes out as a circle        
    if ~mod(theta1-theta2,360) && rho1 == 0
        rho1 = rho2;
        linpts = 1;
    else
        linpts = 12;
    end
    
    % Conversion to radians
    theta1 = theta1 * pi/180;
    theta2 = theta2 * pi/180;
    dtheta = (theta2-theta1)/25;
    
    % dtheta should be at least 1 degrees for a smooth arc border.
    if dtheta > pi/180
        dtheta = pi/180;
    end

    % If a circle, drho is infinity
    drho = (rho2 - rho1)/(linpts - 1);
    
    arc = theta1:dtheta:theta2;
    lin = rho1:drho:rho2;
    
    theta_wedge = [ arc repmat(theta2,1,linpts) ...
        arc(end:-1:1) repmat(theta1,1,linpts)];
    rho_wedge = [ones(1,length(arc))*rho1 lin ...
        ones(1,length(arc))*rho2 lin(end:-1:1)];
    
    
end