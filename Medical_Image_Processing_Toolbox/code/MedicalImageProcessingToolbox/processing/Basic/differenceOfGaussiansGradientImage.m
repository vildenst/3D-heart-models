function [out,kernels] = differenceOfGaussiansGradientImage(im,sigma, varargin)
% out = differenceOfGaussiansGradientImage(im, sigma)
%
% Difference of gaussians
% Works for ImageType and VectorImageType
%
%   sigma is a 2 x 1 vector with the sigma in mm for each Gaussian
%   interp is 'NN' (default), 'linear'
%

MAX_CHUNK_SIZE = 300;

for i=1:size(varargin,2)
    if (strcmp(varargin{i},'maxChunkSize'))
        MAX_CHUNK_SIZE = varargin{i+1};
        i=i+1;
    end
end
%----------------------------

im_ = PatchType(im) ;
im_.data  = im.data ;
    
kernels={};

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
    kernels{i}=kernel;
end
   
out = im_;

end