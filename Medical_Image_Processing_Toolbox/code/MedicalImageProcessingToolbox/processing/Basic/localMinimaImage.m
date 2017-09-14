function out = localMinimaImage(im, radius, varargin)
% out = localMinimaImage(im, radius)
%
% Finds local minima, with minima spanning over radius
% Works for ImageType 
%
%   sigma is a N x 1 vector size of patches in voxels
%


im_ = PatchType(im) ;
im_.data  = im.data ;
    
for i=1:im.ndimensions;
    % This will ensure even number of elements in the kernel
    
    sigma_in_pixels = sigma/im.spacing(i);
    
    N = ceil(max(sigma_in_pixels))*4+1;
    C = N/2;    
    k= gausswin(N,C/sqrt(sigma_in_pixels(1)));
    nelems = ones(1,im.ndimensions);
    nelems(i)=N;

    kernel1 = ones(nelems);
    kernel1(:)=k/sum(k(:));
    %
    k= gausswin(N,C/sqrt(sigma_in_pixels(2)));
    nelems = ones(1,im.ndimensions);
    nelems(i)=N;

    kernel2 = ones(nelems);
    kernel2(:)=k/sum(k(:));
    
    if sigma(2) >= sigma(1)
        kernel = kernel2-kernel1;
    else
        kernel = kernel1-kernel2;
    end

    im_.data = convn(im_.data,kernel,'same');
end
   
out = im_;

end