%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: 
%           Full resolution quality indexes. 
% 
% Interface:
%           [QNR_like, Dl, Ds, QNR_like_map, Dl_map, Ds_map] = indexes_evaluation_FR(I_F,I_MS_LR,I_MS,I_PAN,L,th_values,ratio,S,sensor,tag_qnr,tag_ab)
%
% Inputs:
%           I_F:             Fused image;
%           I_MS_LR:         MS image;
%           I_MS:            MS image upsampled to the PAN size;
%           I_PAN:           Panchromatic image;
%           L:               Image radiometric resolution; 
%           th_values:       Flag. If th_values == 1, apply an hard threshold to the dynamic range;
%           ratio:           Scale ratio between MS and PAN. Pre-condition: Integer value;
%           S:               Block size (optional); Default value: 32;
%           sensor:          String for type of sensor (e.g.,'QB','IKONOS,'GeoEye1','WV2','WV3' or 'none');
%           tag_qnr:         Choice of the QNR-like protocol ('QNR','FQNR','HQNR' or 'RQNR')
%           tag_ab:          Choice of the expontential weights ('unitary','sensor-based','overall')
%
% Outputs:
%           QNR_like         QNR_like index;
%           Dl:              D_l spectral distortion index;
%           Ds:              D_s spatial distortion index.
%           QNR_like_map:    QNR_like quality map;
%           Dl_map:          D_l spectral distortion map;
%           Ds_map:          D_s spatial distortion map.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [metrics, QNR_like_map] = indexes_evaluation_FR(I_F, I_MS_LR, I_MS, I_PAN, L, th_values, ratio, S, psf, choose_metrics, tag_ab)
% [QNR_like, Dl, Ds, QNR_like_map]
metrics = struct();

if th_values
    I_F(I_F > 2^L) = 2^L;
    I_F(I_F < 0) = 0;
end

ind = contains(choose_metrics, 'QNR');
tag_qnr = choose_metrics(ind);
switch tag_qnr
    case 'QNR'
        [a_Q, b_Q] = get_alpha_beta('QNR', tag_ab, 'overall');
        [metrics1{1:3}, QNR_like_map, Dl_map, Ds_map] = QNR(I_F, I_MS, I_MS_LR, I_PAN, ratio, S, a_Q, b_Q);      % QNR_like, Dl, Ds
    case 'FQNR'
        [a_F, b_F] = get_alpha_beta('FQNR', tag_ab, 'overall');
        [metrics1{1:3}, QNR_like_map, Dl_map, Ds_map] = FQNR(I_F, I_MS, I_MS_LR, I_PAN, ratio, S, psf, a_F, b_F);
    case 'HQNR'
        [a_H, b_H] = get_alpha_beta('HQNR', tag_ab, 'overall');
        [metrics1{1:3}, QNR_like_map, Dl_map, Ds_map] = HQNR(I_F, I_MS, I_MS_LR, I_PAN, ratio, S, psf, a_H, b_H);
    case 'RQNR'
        [a_R, b_R] = get_alpha_beta('RQNR', tag_ab, 'overall');
        [metrics1{1:3}, QNR_like_map, Dl_map, Ds_map] = RQNR(I_F, I_MS, I_PAN, ratio, S, psf, a_R, b_R);
end

if ismember("QNR", choose_metrics)
    metrics.QNR=metrics1{1};
end
if ismember("HQNR", choose_metrics)
    metrics.HQNR=metrics1{1};
end
if ismember("FQNR", choose_metrics)
    metrics.RQNR=metrics1{1};
end
if ismember("RQNR", choose_metrics)
    metrics.RQNR=metrics1{1};
end
if ismember("D_L", choose_metrics)
    metrics.D_L=metrics1{2};
end
if ismember("D_S", choose_metrics)
    metrics.D_S=metrics1{3};
end


end
