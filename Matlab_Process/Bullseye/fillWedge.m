% PATCHCHIDLREN = FILLWEDGE(vec,rho1,rho2,theta1,theta2) creates a 
% wedge "patch" using xdata/ydata from a polar plot. The color of the patch 
% is determined scaled by the value of the vector. To be used with
% createBullseye. In order to not have the vector automatically scaled, the
% max of the vector should not be larger than 1.
% 
%   -vec: 1XN vector corresponding to the color of the patch
%   -rho1/2: Inner/outer radius of the wedge, respectively
%   -theta1/theta2: Start/end angle of wedge, in degrees
%
% The maximum wedge size is 359.99 degrees. 
% 
% =========================================================================
% Adrian Lam                                                  Oshinski Lab
% August 4 2014                   
% =========================================================================

function patchChildren = fillWedge(vec,theta1,theta2,rho1,rho2)

    if length(vec) > 1
        dtheta = (theta2 - theta1)/(length(vec));
    else
        dtheta = (theta2 - theta1);
    end
    
    scale = 1;
   
       
    for i = 1:length(vec)
        
        if dtheta == 360
            
            if rho1 == 0  
            
                t = 0:0.01:2*pi;
                x = sin(t) * rho2;
                y = cos(t) * rho2;
                
            else
                
                t = 0:0.01:2*pi;
                x = [ sin(t) * rho1 sin(t) * rho2 0 ];
                y = [ cos(t) * rho1 cos(t) * rho2 0 ];
                
            end

        else
            
            theta1 + dtheta*(i-1);
            
            [theta,rho] = getWedgeBorder(theta1 + dtheta*(i-1), ...
                theta1 + dtheta*i,rho1,rho2);
            [x,y] = pol2cart(theta,rho);
        end
        
        p = patch(x,y,[vec(i)]/scale);
        set( p,'EdgeAlpha',0);
        
    end
    
    tmp = findall(gca,'Type','patch');
    patchChildren = tmp(1:length(vec));
    

end