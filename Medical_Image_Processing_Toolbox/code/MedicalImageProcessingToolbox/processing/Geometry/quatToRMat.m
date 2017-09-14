% Converts a quaternion to a 3x3 rotation matrix
function RMat = quatToRMat(quat)

quat = quat / norm(quat);

q00 = quat(1) * quat(1);
q0x = quat(1) * quat(2);
q0y = quat(1) * quat(3);
q0z = quat(1) * quat(4);
qxx = quat(2) * quat(2);
qxy = quat(2) * quat(3);
qxz = quat(2) * quat(4);
qyy = quat(3) * quat(3);
qyz = quat(3) * quat(4);
qzz = quat(4) * quat(4);

RMat = zeros(3,3);
RMat(1,1) = q00 + qxx - qyy - qzz;
RMat(1,2) = 2 * (qxy - q0z);
RMat(1,3) = 2 * (qxz + q0y);
RMat(2,1) = 2 * (qxy + q0z);
RMat(2,2) = q00 - qxx + qyy - qzz;
RMat(2,3) = 2 * (qyz - q0x);
RMat(3,1) = 2 * (qxz - q0y);
RMat(3,2) = 2 * (qyz + q0x);
RMat(3,3) = q00 - qxx - qyy + qzz;

end