function [gt, pan, ms, lms] = segImg_HSI( PAN,MS, MS_lr, MS_inter, size_l, size_h, scale, overlap)

[h, w, band]   = size(MS_lr);   % size of LR
H = scale*h; W = scale*w;
size_low       = size_l; % patch size of LR
size_high      = size_h;
overlap_low    = overlap;  %  overlap of LR
overlap_h      = scale*overlap; % overlap of HR

% set patch indexs
%---- LR indexs ---------
gridy = 1:size_low - overlap_low : w-(mod(w,size_low-overlap_low)+1+size_low-overlap_low);
gridy = setdiff(gridy, (w-size_low+1):w);  % delete rest elements
gridx = 1:size_low - overlap_low: h-(mod(h,size_low-overlap_low)+1+size_low-overlap_low);
gridx = setdiff(gridx, (h-size_low+1):h); % delete rest elements
%---- HR indexs ---------
Gridy = 1:size_h - overlap_h : W-(mod(W,size_h-overlap_h)+1+size_h-overlap_h);   % is 2 or 8? ===>must be some problem here!
Gridy = setdiff(Gridy, (W-size_h+1):W);  % delete rest elements
Gridx = 1:size_h - overlap_h : H-(mod(H,size_h-overlap_h)+1+size_h-overlap_h);
Gridx = setdiff(Gridx, (H-size_h+1):H);  % delete rest elements


gt   = zeros(size(gridx,2)*size(gridy,2), size_high, size_high, band);
lms  = zeros(size(gridx,2)*size(gridy,2), size_high, size_high, band);

ms = zeros(size(gridx,2)*size(gridy,2), size_high/scale, size_high/scale, band);
% ms   = zeros(size(gridx,2)*size(gridy,2), size_high, size_high, band);

pan  = zeros(size(gridx,2)*size(gridy,2), size_high, size_high,4);

cnt  = 0;
Num  = 0;

for i = 1: length(gridx)
    for j = 1:length(gridy)
        cnt = cnt + 1;
        Num = Num + 1;
        
        xx  = gridx(i);
        yy  = gridy(j);
        XX  = Gridx(i);
        YY  = Gridy(j);
        
        % ---MS_gt img (gt)-----
        ms_p    = MS(XX:XX+size_h-1, YY:YY+size_h-1, :);  % ms_p=24x24x31
        gt(Num, :, :, :) = ms_p;
        
        % ---MS_lr img (ms)-----
        ms_low  = MS_lr(xx:xx+size_l-1, yy:yy+size_l-1, :); % ms_low=6x6x31
        ms_low = double(ms_low);
        % high pass
%         for k = 1 : band
%             ms_low_ave(k) = mean(mean(ms_low(:,:,k)));
%             hp_ms(:,:,k) = ms_low(:,:,k) - ms_low_ave(k);
%         end
        ms(Num, :, :, :) = ms_low;
        
        % if upsample
%         hp_ms_up = imresize(hp_ms, scale);
%         ms(Num, :, :, :) = hp_ms_up;
        
        % ---MS_interpolation img (lms)-----
        ms_int  = MS_inter(XX:XX+size_h-1, YY:YY+size_h-1, :); % ms_int=24x24x31
        lms(Num, :, :, :) = ms_int;
        
        % ---RGB img-----
        pan_p   = PAN(XX:XX+size_h-1, YY:YY+size_h-1,:); % rgb_p=24x24x3
        pan_p = double(pan_p);
        %high pass:

        pan(Num , :, :,:) = pan_p;
        
%         if Num == 10  % to see if there needs registration!
%             ww(:,:,1)=MS(:,:,5);
%             ww(:,:,2)=MS(:,:,3);
%             ww(:,:,3)=MS(:,:,2);
%             ww2(:,:,1)=MS_inter(:,:,5);
%             ww2(:,:,2)=MS_inter(:,:,3);
%             ww2(:,:,3)=MS_inter(:,:,2);
%             pp       = RGB;
%             figure,
%             subplot(1,3,1), imshow(double(ww)/2^16);title('MS')
%             subplot(1,3,2), imshow(double(rgb)/2^8);title('RGB')
%             subplot(1,3,3), imshow(double(ww2)/2^16);title('MS-inter')
%         end
        
    end
end


end


