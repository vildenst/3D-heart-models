function out = gaussND(s,varargin)
% create a ND gaussian
% out = resampleImage(im,0,'spacing',spacing)

blur_sigma = [2 2 2]';

for i=1:size(varargin,2)

    if (strcmp(varargin{i},'blurSigma'))
        blur_sigma=varargin{i+1};
    end
    
end

ndims_ = numel(s);
    
dat = zeros(s(:)');
idx= floor(s(3)/2);
for i=ndims_:-1:2
   idx = idx*s(i-1)+floor(s(i-1)/2);
end
dat(idx)=1;

for i=1:ndims_
        % This will ensure even number of elements in the kernel
        N = s(i);
        k= gausswin(N,2/blur_sigma(i));
        
        nelems = ones(1,ndims_);
        nelems(i)=N;
        
        kernel = ones(nelems);
        kernel(:)=k/sum(k(:));
        
        dat = convn(dat,kernel,'same');
end

out = dat/max(dat(:));

end