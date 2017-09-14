function out  = gaussianBlurImage(im,varargin)
% out = gaussianBlurImage(im)
%
% Fast gaussian blur
% Works for ImageType
%

filter_size = 5;
sigma = 1.5;
dbg = false;
for i=1:size(varargin,2)
    if (strcmp(varargin{i},'dbg'))
        dbg=true;
    elseif (strcmp(varargin{i},'kernelSize'))
        filter_size=varargin{i+1};
    elseif (strcmp(varargin{i},'kernelSigma'))
        sigma=varargin{i+1};
    end
    
end
%----------------------------

% maybe something wrong: the transpose matlab
% Using the derivative of a Gaussian to guarantee smoothness

d_gaussian_plain = kernelOfGaussian(filter_size, sigma, im.ndimensions, im.spacing);
%d_gaussian_kernel = d_gaussian_plain/sum(abs(d_gaussian_plain(:)));
d_gaussian_plain = d_gaussian_plain/sum(d_gaussian_plain(:).^2);

out = convn(im.data,d_gaussian_plain,'same');%/im.spacing(d);

end

function d_gaussian_kernel = kernelOfGaussian(filter_size, sigma_, ndimensions, spacing)
% example of inputs:
%filter_size = 5;
%sigma = 3; % in pixels

filter_radius = floor(filter_size/2);
sigma = sigma_;

if numel(filter_radius)==1
    filter_radius = filter_radius*ones(ndimensions,1);
end
if numel(sigma)==1
    sigma = sigma*ones(ndimensions,1);
end

% Below will give me the gaussian function along direction d. For example,
% for a 3D image and along direction y:
%d_gaussian_func_2 =@(x,y,z) exp(-(x.^2)/(2*sigma^2)).*-y/(sigma^2).*exp(-(y.^2)/(2*sigma^2)).*exp(-(z.^2)/(2*sigma^2));
str2='';
str3 ='';
str4 = '';

for i=1:ndimensions
    str2=[str2 'x' num2str(i) ','];
    str3 = [str3 'exp(-(x' num2str(i) '.^2)/(2*(sigma(' num2str(i) ')*spacing(' num2str(i) '))^2)).*'];
    str4 = [str4 '(-filter_radius(' num2str(i) '):filter_radius(' num2str(i) '))*spacing(' num2str(i) '),'];
end

eval([ '[' str2(1:end-1) ']=ndgrid(' str4(1:end-1) ');']);
eval(['d_gaussian_kernel=  ' str3(1:end-2) ';']);

end