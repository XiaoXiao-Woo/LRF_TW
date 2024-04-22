function showImageErr(Ori_Imag, Output, flag_cut_bounds,dim_cut, location3, location4, range_bar, print_fig, flagvisible, flag_zoomin, flag_colorbar, flag_color_map, filename, task)
% This is a demo to show the error map of GT and Estimated Img
n_size = size(Ori_Imag);
dims = ndims(Ori_Imag);
if dims == 2
    channel = 1;
    frame = 1;
elseif dims ==3
    if strcmp(task, 'hisr')
    channel = [31 20 10]; 
    frame = 1;
    elseif n_size(end) == 8
       channel = [1, 3, 5];
       frame = 1;
    else
       channel = [1, 2, 3];
       frame = 1;
    end
elseif dims==4
    channel = [1 2 3];
    frame = 13;
end
%
Multi_Err = abs(Ori_Imag(:, :, channel, frame) - Output(:, :, channel, frame));
ErrMap = mean(Multi_Err,3);
% ent = (ErrMap-min(ErrMap(:))) / (max(ErrMap(:))-min(ErrMap(:)));  %  * 256
% ent = uint16(ent * 1023);
ent = ErrMap / max(ErrMap(:));
% ent = uint16(ErrMap);
% ent = ErrMap;
% v = uint16(max(ent(:)));
% ent = imadjust(ent, [0, 1]);
if flag_cut_bounds
    ent = ent(dim_cut:end-dim_cut,dim_cut:end-dim_cut,:);
end
% cmap = parula(256);
% ent = gray2color(ErrMap,map,0,1);
% if ~strcmp(flag_color_map, '')
% %     colormap(flag_color_map)
%     ent = ind2rgb(ent, jet(1023)); 
% end

% figure('visible', flagvisible, 'Name', alg) %'NumberTitle', 'off',
if flag_zoomin
    if isempty(location4)
        ent=rectangleonimage(ent,location3, 0.5, 3, 1, 2, 1);  % put close-up to up-right corner
%         imshow(ent,[])
    else
        % type =1 (put to down-left); type =2 (put to down-right); 
        % type =3 (put to up-right); type =4 (put to up-left); 
        ent = rectangleonimage(ent, location3, 0.5, 1, 1, 2, 3);
        ent = rectangleonimage(ent, location4, 0.5, 1, 2, 2, 2);
%         imshow(ent,[])
    end
end
if print_fig
figure('visible', flagvisible),
end
if ~contains(filename, "GT")
    imshow(ent,[])
else
    imshow(ent)
end
%#######################
caxis(range_bar)
% colorbar('horizontal');
% colormap parula
if ~strcmp(flag_color_map, '')
    colormap(flag_color_map)
end
if ismember(string(flag_colorbar), ["horizontal","vertical"])
    colorbar(flag_colorbar);
end
axis off
set(gcf,'color','white');
%#######################

if print_fig
%     f = figure('visible', 0);
%     imshow(ErrMap,[])
%     caxis(range_bar)
%     colorbar;
%     colormap(f,'parula')
%     axis off
%     printImage(IMN,sprintf('Outputs/%d.eps',id));
%     print('-depsc', strcat(filename, '.eps'));
%     set(gcf,'PaperSize',[29.7 21.0], 'PaperPosition',[0 0 29.7 21.0])
%     set(gca, 'Position', get(gca, 'OuterPosition') - ...
%     get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);
%     set(gcf,'Units','inches');
%     frame=getframe(gcf);
%     imwrite(frame2im(frame), strcat(filename, '.png'));
%     screenposition = get(gcf,'Position');
%     set(gcf,...
%         'PaperPosition',[0 0 screenposition(3:4)],...
%         'PaperSize',[screenposition(3:4)]);
%     print('-dsvg', gcf, strcat(filename, '.svg'));
    export_fig(strcat(filename, '.png'),'-native')
    fprintf("save Err image in %s\n", strcat(filename, '.png'));
    
end

end
