function p = psnr_index(x,y,img_range)
% psnr - compute the Peack Signal to Noise Ratio, defined by :
p=10*log10(img_range^2/mse(x-y));



