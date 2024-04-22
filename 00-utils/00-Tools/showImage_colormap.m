function showImage_colormap(img, flag_cut_bounds, dim_cut, range_bar, print_fig, flagvisible, flag_colorbar, flag_color_map, filename)
% This is a demo to show the color map of Img with one channel.

if flag_cut_bounds
    img = img(dim_cut:end-dim_cut,dim_cut:end-dim_cut,:);
end

if print_fig
figure('visible', flagvisible),
end
imshow(img,[])
%#######################
caxis(range_bar)
if ismember(string(flag_colorbar), ["horizontal","vertical"])
    colorbar(flag_colorbar);
end
if ~strcmp(flag_color_map, '')
    colormap(flag_color_map)
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
    fprintf("save QNR-like image in %s\n", strcat(filename, '.png'));
    
end

end
