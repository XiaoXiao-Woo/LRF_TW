function showRGB(Ori_Imag, Output, location3, location4, alg, print_fig, flagvisible, zoom_in, filename)
dims = ndims(Ori_Imag);
n_size = size(Ori_Imag);
nbands = n_size(end);
if dims > 2
    if nbands==3
        channel = [1 2 3];
    elseif dims==4
        channel = [1 2 3];
        Ori_Imag = Ori_Imag(:, :, :, 1);
    else
        channel = [31 20 10];
    end
else
    channel = 1;
end
%
% th_MSrgb = image_quantile(Ori_Imag(:,:,channel), [0.01 0.99]);
% I_fuse = image_stretch(Output(:,:,channel),th_MSrgb);
I_fuse = Ori_Imag(:,:,channel);
if zoom_in
    ent = rectangleonimage(I_fuse, location3, 0.5, 3, 1, 2, 1);
else
    ent = I_fuse;
end

if print_fig
    f = figure('visible', flagvisible, 'Name', alg);
    imshow(ent,[],'border','tight','initialmagnification','fit')
    imwrite(ent, strcat(filename, '.png'))
    %     printImage(IMN,sprintf('Outputs/%d.eps',id));
%     print('-depsc', strcat(filename, '.eps'));
    %     set(gcf,'PaperSize',[29.7 21.0], 'PaperPosition',[0 0 29.7 21.0])
%     set(f,'Units','inches');
%     screenposition = get(f,'Position');
%     set(f,...
%         'PaperPosition',[0 0 screenposition(3:4)],...
%         'PaperSize',[screenposition(3:4)]);
%     set(gca, 'Position', get(gca, 'OuterPosition') - ...
%     get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);
%     print('-dsvg', f, strcat(filename, '.svg'));
%     export_fig(strcat(filename, '.png'),'-native')
    fprintf("save RGB image in %s\n", strcat(filename, '.png'));
else
%     figure('visible', flagvisible, 'Name', alg) %'NumberTitle', 'off',
    imshow(ent,[])
end

end