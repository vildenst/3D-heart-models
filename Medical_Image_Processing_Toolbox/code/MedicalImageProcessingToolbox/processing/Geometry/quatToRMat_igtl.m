% Converts a quaternion to a 3quat(1)3 rotation matriquat(1)
function RMat = quatToRMat_igtl(quat)

quat = quat / norm(quat);
  
q00 = quat(1) * quat(1)*2; % xx
q0x = quat(1) * quat(2)*2; % xy
q0y = quat(1) * quat(3)*2; % xz
q0z = quat(1) * quat(4)*2; % xw
qxx = quat(2) * quat(2)*2; % yy
qxy = quat(2) * quat(3)*2; % yz
qxz = quat(2) * quat(4)*2; % yw
qyy = quat(3) * quat(3)*2; % zz
qyz = quat(3) * quat(4)*2; % zw
qzz = quat(4) * quat(4)*2; % ww

RMat(1,1) = 1.0 - (qxx + qyy);
RMat(1,2) =q0x -qyz;
RMat(1,3) =q0y + qxz;

RMat(2,1) = q0x + qyz;
RMat(2,2) = 1.0 -(q00 +qyy);
RMat(2,3) = qxy - q0z;  
  
RMat(3,1) = q0y - qxz;
RMat(3,2) = qxy + q0z;
RMat(3,3) = 1.0 -(q00 + qxx);  
  
   


end