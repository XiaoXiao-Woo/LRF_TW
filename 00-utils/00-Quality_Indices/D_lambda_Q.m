%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: 
%           Quality with No Reference (QNR): Spectral distortion index. 
% 
% Interface:
%           [Dl,Dl_map] = D_lambda_Q(I_F,I_MS,I_MS_LR,ratio,S)
%
% Inputs:
%           I_F:             Pansharpened image;
%           I_MS:            MS image resampled to panchromatic scale;
%           I_MS_LR:         Original MS image;
%           ratio:           Resolution ratio;
%           S:               Block size (optional); Default value: 32;
% 
% Outputs:
%           Dl:              D_lambda index QNR.
%           Dl_map:          D_lambda map QNR.
% 
% References:
%           [Alparone08]     L. Alparone, B. Aiazzi, S. Baronti, A. Garzelli, F. Nencini, and M. Selva, "Multispectral and panchromatic data fusion assessment without reference,"
%                            Photogrammetric Engineering and Remote Sensing, vol. 74, no. 2, pp. 193–200, February 2008. 
%           [Vivone15]       G. Vivone, L. Alparone, J. Chanussot, M. Dalla Mura, A. Garzelli, G. Licciardi, R. Restaino, and L. Wald, “A Critical Comparison Among Pansharpening Algorithms”, 
%                            IEEE Transactions on Geoscience and Remote Sensing, vol. 53, no. 5, pp. 2565–2586, May 2015.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Dl, Dl_map] = D_lambda_Q(I_F, I_MS, I_MS_LR, ratio, S)

% Flag for choosing the computation domain
%  (if 0: domain of expanded MS; 
%   if 1: domain of original MS as proposed in the original QNR paper.)
flag_orig_paper = 0;

% Input check 
if (size(I_F) ~= size(I_MS))
    error('The two input images must have the same dimensions.')
end

[N,M,Nb] = size(I_F);

if (rem(N,S) ~= 0)
    error('The number of rows must be multiple of the block size.')
end

if (rem(M,S) ~= 0)
    error('The number of columns must be multiple of the block size.')
end


Dl = 0;
for i = 1:Nb-1
    for j = i+1:Nb 
        if flag_orig_paper == 0 % Domain of expanded MS
            band1 = I_MS(:,:,i);
            band2 = I_MS(:,:,j);
            fun_uqi = @(bs) uqi(bs.data,...
            band2(bs.location(1):bs.location(1)+S-1,...
            bs.location(2):bs.location(2)+S-1));
            Qmap_exp = blockproc(band1,[S S],fun_uqi);   
           if i==1 && j==2
                Dl_map = zeros(size(Qmap_exp));
                else
            end
        else
            % Domain of original MS
            band1 = I_MS_LR(:,:,i);
            band2 = I_MS_LR(:,:,j);
            fun_uqi = @(bs) uqi(bs.data,...
            band2(bs.location(1):bs.location(1)+S/ratio-1,...
            bs.location(2):bs.location(2)+S/ratio-1));
            Qmap_exp = blockproc(band1,[S/ratio S/ratio],fun_uqi);
            if i==1 && j==2
                Dl_map = zeros(size(Qmap_exp));
                else
            end
        end
        Q_exp = mean2(Qmap_exp);        
        band1 = I_F(:,:,i);
        band2 = I_F(:,:,j);
        fun_uqi = @(bs) uqi(bs.data,...
            band2(bs.location(1):bs.location(1)+S-1,...
            bs.location(2):bs.location(2)+S-1));
        Qmap_fused = blockproc(band1,[S S],fun_uqi);
        Q_fused = mean2(Qmap_fused);        
        Dl = Dl + abs(Q_fused-Q_exp);
        Dl_map = Dl_map + abs(Qmap_fused-Qmap_exp);
    end
end
s = ((Nb^2)-Nb)/2;
Dl = (Dl/s);
Dl_map=(Dl_map/s);
end

% Add. function: UIQI on x and y images %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Q = uqi(x,y)

x = double(x(:));
y = double(y(:));
mx = mean(x);
my = mean(y);
C = cov(x,y);
Q = 4 * C(1,2) * mx * my / (C(1,1)+C(2,2)) / (mx^2 + my^2);  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end