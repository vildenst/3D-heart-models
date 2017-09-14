function point = sphereRandomPoint(N)
%point = sphereRandomPoint()
% Returns N uniformly distributed point randomly picked from the unit
% sphere. More details on http://mathworld.wolfram.com/SpherePointPicking.html

u = (rand(N,1)-0.5)*2;
theta = rand(N,1)*2*pi;

point = zeros(N,3);
point(:,1) = sqrt(1-u.^2).*cos(theta);
point(:,2) = sqrt(1-u.^2).*sin(theta);
point(:,3) =u; 


end

