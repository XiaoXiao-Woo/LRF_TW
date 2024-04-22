%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: 
%           Full resolution quality indexes. 
% 
% Interface:
%           [D_lambda,D_S,QNR_index,SAM_index,sCC] = indexes_evaluation_FS(I_F,I_MS_LR,I_PAN,L,th_values,I_MS,sensor,tag,ratio)
%
% Inputs:
%           I_F:                Fused image;
%           I_MS_LR:            MS image;
%           I_PAN:              Panchromatic image;
%           L:                  Image radiometric resolution; 
%           th_values:          Flag. If th_values == 1, apply an hard threshold to the dynamic range;
%           I_MS:               MS image upsampled to the PAN size;
%           sensor:             String for type of sensor (e.g. 'WV2','IKONOS');
%           ratio:              Scale ratio between MS and PAN. Pre-condition: Integer value;
%           flagQNR:            if flagQNR == 1, the software uses the QNR otherwise the HQNR is used.
%
% Outputs:
%           D_lambda:           D_lambda index;
%           D_S:                D_S index;
%           QNR_index:          QNR index;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [metrics,QNR_like_map] = indexes_evaluation_FS(I_F,I_MS_LR,I_PAN,L,th_values,I_MS,psf,ratio,Qblocks_size, flagQNR, choose_metrics)
% [D_lambda,D_S,QNR_index]
metrics = struct();
if th_values
    I_F(I_F > 2^L) = 2^L;
    I_F(I_F < 0) = 0;
end

addpath('./Quality_Indices/bak')

if ismember("QNR", choose_metrics)
    metrics1(1:3) = QNR(I_F,I_MS,I_MS_LR,I_PAN,ratio); %[QNR_index,D_lambda,D_S]
elseif ismember("HQNR", choose_metrics)
    metrics1(1:3) = HQNR(I_F,I_MS_LR,I_MS,I_PAN,Qblocks_size,psf,ratio); % [QNR_index,D_lambda,D_S]
end

if ismember("QNR", choose_metrics)
    metrics.QNR=metrics1(1);
end
if ismember("HQNR", choose_metrics)
    metrics.HQNR=metrics1(1);
end
if ismember("D_L", choose_metrics)
    metrics.D_lambda=metrics1(2);
end
if ismember("D_S", choose_metrics)
    metrics.D_S=metrics1(3);
end

rmpath('./Quality_Indices/bak')
QNR_like_map = zeros(size(I_F));
end