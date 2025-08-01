%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: 
%           Visualize and print an eight-band multispectral image.
% 
% Interface:
%           showImage8(I_MS,print,id,flag_cut_bounds,dim_cut,th_values,L)
%
% Inputs:
%           I_MS:               Eight band multispectral image;
%           print:              Flag. If print == 1, print EPS image;
%           id:                 Identifier (name) of the printed EPS image;
%           flag_cut_bounds:    Cut the boundaries of the viewed Panchromatic image;
%           dim_cut:            Define the dimension of the boundary cut;
%           th_values:          Flag. If th_values == 1, apply an hard threshold to the dynamic range;
%           L:                  Radiomatric resolution of the input image.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function showImage8(I_MS,print,id,flag_cut_bounds,dim_cut,th_values,L, alg, flagvisible, filename)

if size(I_MS,3) == 4
    index = 1:3;
else
    index = [1,3,5];
end

if flag_cut_bounds
    I_MS = I_MS(dim_cut:end-dim_cut,dim_cut:end-dim_cut,:);
end

if th_values
    I_MS(I_MS > 2^L) = 2^L;
    I_MS(I_MS < 0) = 0;
end

if id == 1
    IMN = viewimage(I_MS(:,:,index), alg, flagvisible);
    IMN = IMN(:,:,3:-1:1);
else
    IMN = viewimage(I_MS(:,:,index), alg, flagvisible,[0.01 0.995]);
    IMN = IMN(:,:,3:-1:1);
end

if print
%     printImage(IMN,sprintf('Outputs/%d.eps',id));
%         print('-depsc', filename);
        set(gcf,'Units','inches');
    screenposition = get(gcf,'Position');
    set(gcf,...
        'PaperPosition',[0 0 screenposition(3:4)],...
        'PaperSize',[screenposition(3:4)]);
    print('-dpdf', strcat(filename, '.pdf'));
end

end