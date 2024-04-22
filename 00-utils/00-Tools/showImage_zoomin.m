%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: 
%           Visualize and print a four-band multispectral image.
% 
% Interface:
%           showImage4(I_F,print,id,flag_cut_bounds,dim_cut,thvalues,L)
%
% Inputs:
%           I_MS:               Four band multispectral image;
%           print:              Flag. If print == 1, print EPS image;
%           id:                 Identifier (name) of the printed EPS image;
%           flag_cut_bounds:    Cut the boundaries of the viewed Panchromatic image;
%           dim_cut:            Define the dimension of the boundary cut;
%           th_values:          Flag. If th_values == 1, apply an hard threshold to the dynamic range;
%           L:                  Radiomatric resolution of the input image.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function showImage_zoomin(I_MS,printEPS,id,flag_cut_bounds,dim_cut,th_values,L, location1, location2, alg, flagvisible, flag_zoomin, filename)

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

IMN = viewimage(I_MS(:,:,index), alg, flagvisible);
IMN = IMN(:,:,3:-1:1);

if flag_zoomin
    if isempty(location2)
        ent=rectangleonimage(IMN,location1,1, 3, 3, 3, 1);  % put close-up to up-right corner
        imshow(ent,[])
    else
        % type =1 (put to down-left); type =2 (put to down-right); 
        % type =3 (put to up-right); type =4 (put to up-left); 
        ent=rectangleonimage(IMN,location1,0.5, 3, 1, 2, 3);  % put close-up to up-right corner
        ent=rectangleonimage(ent,location2,0.5, 3, 2, 2, 2);   % put close-up to down-right corner
    %     figure('Name', strcat(alg,'_2')), 
        imshow(ent,[])
    end
else
    ent = IMN;
    imshow(ent,[])
end

if printEPS
%     printImage(IMN,sprintf('Outputs/%d.eps',id));
%         print('-depsc', filename);
    set(gcf,'Units','inches');
    screenposition = get(gcf,'Position');
    set(gcf,...
        'PaperPosition',[0 0 screenposition(3:4)],...
        'PaperSize',[screenposition(3:4)]);
%     print('-dpdf', strcat(filename, '.pdf'));
    imwrite(ent, strcat(filename, '.png'));
end

end