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
function IN = showPan_zoomin(Pan,print_fig,id,flag_cut_bounds,dim_cut, location1, location2, alg, flagvisible, flag_zoomin, filename)

ratio = 4;
if flag_cut_bounds
    Pan = Pan(dim_cut:end-dim_cut,dim_cut:end-dim_cut,:);
%     Pan = Pan(round(dim_cut/ratio):end-round(dim_cut/ratio),round(dim_cut/ratio):end-round(dim_cut/ratio),:);

end

IN = viewimage(Pan, alg, flagvisible);

if flag_zoomin
    if isempty(location2)
        ent=rectangleonimage(IN,location1,1, 3, 3, 3, 1);  % put close-up to up-right corner
    %     figure('NumberTitle', 'off', 'Name', alg),
        imshow(ent,[])
    else
        % type =1 (put to down-left); type =2 (put to down-right); 
        % type =3 (put to up-right); type =4 (put to up-left); 
        ent=rectangleonimage(IN,location1,0.5, 3, 1, 2, 3);  % put close-up to up-right corner
        ent=rectangleonimage(ent,location2,0.5, 3, 2, 2, 2);   % put close-up to down-right corner
    %     figure('Name', strcat(alg,'_2')),
        imshow(ent,[])
    end
else
    ent = IN;
    imshow(ent,[])
end
    
    
if print_fig
%     printImage(IN,sprintf('Outputs/%d.eps',id));
%     print('-depsc', filename);
        set(gcf,'Units','inches');
    screenposition = get(gcf,'Position');
    set(gcf,...
        'PaperPosition',[0 0 screenposition(3:4)],...
        'PaperSize',[screenposition(3:4)]);
%     print('-dpdf', strcat(filename, '.pdf'));
    imwrite(ent, strcat(filename, '.png'));
end

end