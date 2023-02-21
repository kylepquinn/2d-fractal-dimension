function fractalDimension = modifiedBlanket2D(img,kernelSize)
% fractalDimension = MODIFIEDBLANKET2D(img,kernelSize) 
% returns the pixel-wise map of local fractal dimension (fractalDimension) for an
% input image (img) based on a local window (kernelSize).
%
% Created by: Isaac Vargas 2018
% Published work: https://doi.org/10.1364/BOE.9.005269
%
% Edited by: Alan Woessner (aeweossn@gmail.com) 2/20/2023
%
% Maintained by: Kyle Quinn (kpquinn@uark.edu)
%                Quantitative Tissue Diagnostics Laboratory (Quinn Lab)
%                University of Arkansas   
%                Fayetteville, AR 72701

% Set up kernels
kernel_hor=[1 -1 0];
kernel_ver=[0;-1;1];
hk=fspecial('disk',kernelSize)*kernelSize^2*pi;
j=0;

% Resizing and Image Analysis Loop
surfaceArea = zeros([size(img),kernelSize],'single');
pixelSize = zeros(1,kernelSize);

for i = kernelSize:-1:1
    newimsize=round(i/kernelSize*size(img,1));
    hk2=imresize(hk,[i i]);
        
    j=j+1; 
    Image_resized=imresize(single(img),[newimsize newimsize]);
      
    Imagef_hor=imfilter(Image_resized,kernel_hor,'symmetric');
    Imagef_ver=imfilter(Image_resized,kernel_ver,'symmetric');
    
    Ih=imfilter(abs(Imagef_hor),hk2,'symmetric');

    Iv=imfilter(abs(Imagef_ver),hk2,'symmetric');

    surfaceArea(:,:,j)=imresize(size(img,1)/i/kernelSize*(Ih+Iv),size(img));

    pixelSize(j)=size(img,1)/i*kernelSize;
end

% Fix 0 values for log transform
surfaceArea(surfaceArea<=0) = 1;

% Calculate the slope of log(surfaceArea) vs log(pixelSize)
x = log(pixelSize);
y = log(surfaceArea);

% Ignore the first entry
x = x(2:end);
y = y(:,:,2:end);

% Calculate slope using a finite centered differece approximation
slope = zeros([size(img),length(x)],'single');
slope(:,:,1) = (y(:,:,2) - y(:,:,1)) / (x(2) - x(1));
for i = 2:length(x)-1
    slope(:,:,i) = (y(:,:,i+1) - y(:,:,i-1)) ./ (x(i+1) - x(i-1));
end
slope(:,:,length(x)) = (y(:,:,end) - y(:,:,end-1)) ./ (x(end) - x(end-1));

% Calculate 2D fractal dimension
fractalDimension = 2 - squeeze(mean(slope,3));

fractalDimension(fractalDimension<0) = 0;
fractalDimension(isinf(fractalDimension) | isnan(fractalDimension)) = 0;
end



