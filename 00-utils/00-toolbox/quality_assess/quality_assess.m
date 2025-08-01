function [psnr, ssim] = quality_assess(imagery1, imagery2)
%==========================================================================
% Evaluates the quality assessment indices for two tensors.
%
% Syntax:
%   [psnr, ssim] = quality(imagery1, imagery2)
%
% Input:
%   imagery1 - the reference tensor
%   imagery2 - the target tensor

% NOTE: the tensor is a I1*I2*...*IN array and DYNAMIC RANGE [0, 255]. 
% Output:
%   psnr - Peak Signal-to-Noise Ratio
%   ssim - Structure SIMilarity
%
% by Yi Peng
% Updated by Yu-Bang Zheng 11/19/2019
%==========================================================================
Nway = size(imagery1);
if length(Nway)>3
    imagery1 = reshape(imagery1,Nway(1),Nway(2),[]);
    imagery2 = reshape(imagery2,Nway(1),Nway(2),[]);
end
% if max(imagery2(:)) <= 1
%     imagery2 = imagery2 * maxvalue;
% end
% if max(imagery1(:))<=1
%     imagery1 = imagery1 * maxvalue;
% end

psnr = zeros(prod(Nway(3:end)),1);
ssim = psnr;
for i = 1:prod(Nway(3:end))
    psnr(i) = psnr_index(imagery1(:, :, i), imagery2(:, :, i));
    ssim(i) = ssim_index(imagery1(:, :, i), imagery2(:, :, i));
end
psnr = mean(psnr);
ssim = mean(ssim);

