%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: 
%           Reduced resolution quality indexes. 
% 
% Interface:
%           [Q_index, SAM_index, ERGAS_index, sCC, Q2n_index] = indexes_evaluation(I_F,I_GT,ratio,L,Q_blocks_size,flag_cut_bounds,dim_cut,th_values)
%
% Inputs:
%           I_F:                Fused Image;
%           I_GT:               Ground-Truth image;
%           ratio:              Scale ratio between MS and PAN. Pre-condition: Integer value;
%           L:                  Image radiometric resolution; 
%           Q_blocks_size:      Block size of the Q-index locally applied;
%           flag_cut_bounds:    Cut the boundaries of the viewed Panchromatic image;
%           dim_cut:            Define the dimension of the boundary cut;
%           th_values:          Flag. If th_values == 1, apply an hard threshold to the dynamic range.
%
% Outputs:
%           Q_index:            Q index;
%           SAM_index:          Spectral Angle Mapper (SAM) index;
%           ERGAS_index:        Erreur Relative Globale Adimensionnelle de Synth�se (ERGAS) index;
%           sCC:                spatial Correlation Coefficient between fused and ground-truth images;
%           Q2n_index:          Q2n index.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function metrics = indexes_evaluation(I_F,I_GT,ratio,L,Q_blocks_size,flag_cut_bounds,dim_cut,th_values,maxvalue,choose_metrics)
% [psnr, ssim, Q_index, SAM_index, ERGAS_index, cc, sCC, Q2n_index, rmse]
metrics = struct();

if max(I_GT(:))>1
    I_GT = I_GT/maxvalue;
    I_F = I_F/maxvalue;
end

if th_values
    I_F(I_F > 2^L) = 2^L;
    I_F(I_F < 0) = 0;
end

dim = ndims(I_GT);
[H, W, C, F] = size(I_GT);


if dim == 4
    if flag_cut_bounds
        I_GT = I_GT(dim_cut:end-dim_cut,dim_cut:end-dim_cut,:, :);
        I_F = I_F(dim_cut:end-dim_cut,dim_cut:end-dim_cut,:, :);
    end
    I_GT = reshape(I_GT, [H, W, C*F]);
    I_F = reshape(I_F, [H, W, C*F]);
    
else
    if flag_cut_bounds
        I_GT = I_GT(dim_cut:end-dim_cut,dim_cut:end-dim_cut,:);
        I_F = I_F(dim_cut:end-dim_cut,dim_cut:end-dim_cut,:);
    end

end



% addpath('./Quality_Indices')
if ismember("PSNR", choose_metrics) || ismember("SSIM", choose_metrics)
    metrics1 = quality_assess(I_GT, I_F, 1.0);
    if ismember("PSNR", choose_metrics)
        metrics.PSNR=metrics1(1);
    end
    if ismember("SSIM", choose_metrics)
        metrics.SSIM=metrics1(2);
    end
end

if ismember("PSNR_Y", choose_metrics) || ismember("SSIM_Y", choose_metrics)
    I_GT = rgb2ycbcr(I_GT) * 255.0;
    I_F = rgb2ycbcr(I_F) * 255.0;
    I_GT = I_GT(3:end-2, 3:end-2, 1);
    I_F = I_F(3:end-2, 3:end-2, 1);
    metrics_Y = quality_assess(I_GT, I_F, maxvalue);
    if ismember("PSNR_Y", choose_metrics)
        metrics.PSNR_Y=metrics_Y(1);
    end
    if ismember("SSIM_Y", choose_metrics)
        metrics.SSIM_Y=metrics_Y(2);
    end
end

if ismember("Q2n", choose_metrics)
    metrics.Q2n = q2n(I_GT*maxvalue,I_F*maxvalue,Q_blocks_size,Q_blocks_size);
end
if ismember("Q_avg", choose_metrics)
    metrics.Q = Q(I_GT,I_F,1);
end
if ismember("SAM", choose_metrics)
    metrics.SAM = SAM(I_GT,I_F);
end
if ismember("ERGAS", choose_metrics)
    metrics.ERGAS = ERGAS(I_GT,I_F,ratio);
end
if ismember("SCC", choose_metrics)
    metrics.SCC = SCC(I_F,I_GT);
end
if ismember("CC", choose_metrics)
    cc = CC_a(I_F,I_GT);
    metrics.CC = mean(cc);
end
if ismember("RMSE", choose_metrics)
    metrics.RMSE = RMSE_a(I_F,I_GT);
end

% rmpath('./Quality_Indices')

end