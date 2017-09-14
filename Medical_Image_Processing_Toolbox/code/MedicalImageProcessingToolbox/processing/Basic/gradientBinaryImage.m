function out  = gradientBinaryImage(im,varargin)
% out = gradientImage(im)
%
% Fast gradient of a binary image
% Works for ImageType
%

difforder = 1;
binary=false;
dbg=false;
for i=1:size(varargin,2)
    if (strcmp(varargin{i},'dbg'))
        dbg=true;
    elseif (strcmp(varargin{i},'order'))
        difforder=varargin{1};
    elseif (strcmp(varargin{i},'binary'))
        binary=true;
    end
    
end
%----------------------------

out=[];
% maybe something wrong: the transpose matlab shit
% Using the derivative of a Gaussian to guarantee smoothness
filter_size = 7;
sigma = 1.5; % in pixels

for d=1:im.ndimensions
    [d_gaussian_kernel,d_gaussian_plain] = derivativeOfGaussian(filter_size, sigma, d, im.ndimensions, im.spacing);
    %d_gaussian_kernel = d_gaussian_kernel/sum(abs(d_gaussian_kernel(:)));
    d_gaussian_kernel = d_gaussian_kernel/sum(d_gaussian_plain(:).^2);
    
    dx = convn(im.data,d_gaussian_kernel,'same');%/im.spacing(d);
    
    out = cat(im.ndimensions+1,out,dx);
end

end

function [d_gaussian_kernel_derivative,d_gaussian_kernel] = derivativeOfGaussian(filter_size, sigma_, d, ndimensions, spacing)
% example of inputs:
%filter_size = 5;
%sigma = 3; % in pixels
% d=2 (direction along which we do the derivative)

filter_radius = floor(filter_size/2);
sigma = sigma_ * spacing(d);

% Below will give me the gaussian function along direction d. For example,
% for a 3D image and along direction y:
%d_gaussian_func_2 =@(x,y,z) exp(-(x.^2)/(2*sigma^2)).*-y/(sigma^2).*exp(-(y.^2)/(2*sigma^2)).*exp(-(z.^2)/(2*sigma^2));
str1='';
str2='';
str3 ='';
str4 = '';

for i=1:ndimensions
    str2=[str2 'x' num2str(i) ','];
    if i==d
        str1 = [str1 '-x' num2str(i) '/(sigma^2).*exp(-(x' num2str(i) '.^2)/(2*sigma^2)).*'];
    else
        str1 = [str1 'exp(-(x' num2str(i) '.^2)/(2*sigma^2)).*'];
    end
    str3 = [str3 'exp(-(x' num2str(i) '.^2)/(2*sigma^2)).*'];
    str4 = [str4 '(-filter_radius:filter_radius)*spacing(' num2str(i) '),'];
end

eval([ '[' str2(1:end-1) ']=ndgrid(' str4(1:end-1) ');']);
eval(['d_gaussian_kernel_derivative=  ' str1(1:end-2) ';']);
eval(['d_gaussian_kernel=  ' str3(1:end-2) ';']);






end