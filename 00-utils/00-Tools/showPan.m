%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: 
%           Visualize and print the panchromatic image.
% 
% Interface:
%           showPan(Pan,print,id,flag_cut_bounds,dim_cut)
%
% Inputs:
%           Pan:                Panchromatic image;
%           print:              Flag. If print == 1, print EPS image;
%           id:                 Identifier (name) of the printed EPS image;
%           flag_cut_bounds:    Cut the boundaries of the viewed Panchromatic image;
%           dim_cut:            Define the dimension of the boundary cut;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function IN = showPan(Pan,print,id,flag_cut_bounds,dim_cut, alg, flagvisible, filename)

if flag_cut_bounds
    Pan = Pan(dim_cut:end-dim_cut,dim_cut:end-dim_cut,:);
end

IN = viewimage(Pan, alg, flagvisible);

if print
%     printImage(IN,sprintf('Outputs/%d.eps',id));
        print('-depsc', filename);
        set(gcf,'Units','inches');
    screenposition = get(gcf,'Position');
    set(gcf,...
        'PaperPosition',[0 0 screenposition(3:4)],...
        'PaperSize',[screenposition(3:4)]);
    print('-dpdf', strcat(filename, '.pdf'));
end

end