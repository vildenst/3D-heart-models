function out = setOrientation(im,mat,varargin)
% out = setOrientation(im,mat)
% out = resampleImage(im,mat, options)
%
%   Options:
%       'invert',use inverse matrix
%
%   Works for ImageType and VectorImageType



invert=false;
for i=1:size(varargin,2)
    if (strcmp(varargin{i},'invert'))
        invert=true;
    end
    
end
%----------------------------

n = min([numel(im.spacing) 3]);

imageMatrix = eye(n+1);
imageMatrix(1:n,1:n) = im.orientation(1:n,1:n);
imageMatrix(1:n,n+1) = im.origin(1:n);

if invert
    matrix_use = mat;
else
    matrix_use = inv(mat);  
end

orientation_matrix = matrix_use * imageMatrix;

newOrigin = matrix_use*[im.origin(1:n) ; 1];
no = im.origin;
no(1:n)=newOrigin(1:n);

om = im.orientation;
om(1:n,1:n) = orientation_matrix(1:n,1:n);

if (isa(im,'VectorImageType') || isfield(im,'datax'))
    out = VectorImageType(im.size,no,im.spacing,om);
    vectorsIn = [im.datax(:) im.datay(:) im.dataz(:)]';
    
    vectorsOut = matrix_use(1:n,1:n)*vectorsIn ;
    
    out.datax(:) = vectorsOut(1,:)';
    out.datay(:) = vectorsOut(2,:)';
    if (n==3)
        out.dataz(:) = vectorsOut(3,:)';
    end
    
    % TOSO transform vectors also
else
    out = ImageType(im.size,no,im.spacing,om);
    out.data = im.data;
end





end