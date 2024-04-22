% Xiao Wu (UESTC)
% Last modified in 2024-04-17.

clear all;
addpath(genpath('../00-utils'), '00-build', '00-my_fune', '01-Tool');
addpath(genpath('my_scripts'));
%%
opts.dataset = "cave";
opts.exp_desc = 'test';
opts.task = 'TC';
opts.mode = 'debug';
opts.copy_list = [];
opts.metric = ["PSNR", "SSIM", "SAM"];
opts.metric_rule = "greater";


parser_args();
Alg_names=fieldnames(Algorithms);
Alg_names = ["LRF_TW"];
DL_lists = ["-"];

%%
files = dir("./Datasets/test_data/CAVE_test");
% files = dir("D:/Datasets/video/CV/20");
assert(~isempty(files));
files = files([3:end]);
files = convertCharsToStrings({files.name});
exm_num = length(files);
A_num = length(Algorithms);
Re_tensor = cell(A_num,1);
NumIndexes = length(opts.metric);
MatrixResults = zeros(A_num, NumIndexes);
MatrixTimes = zeros(A_num, 1);
%%
flag_cut_bounds = 0;% Cut Final Image
Qblocks_size = 32; % for Q2n
dim_cut = 30;% Cut Final Image
thvalues = 0;
L = 11;% Radiometric Resolution
maxvalue = 1; %data and results should be normalized to 0-1.
opts.ratio = 1;

printEPS = 1;
flag_show = 1;
flagvisible = 'off';
flag_savemat = 0;
flag_zoomin = 0;

flag_colorbar = 'vertical';
flag_color_map = 'jet';
% flag_colorbar = '';

%%
for sample_ratio = [0.05] % 0.05, 0.1, 0.2
opts.sample_ratio = sample_ratio;
opts.dataset = strcat('cave_', num2str(opts.sample_ratio * 100));
data_name = strcat('3_EPS/', opts.dataset, '/');  % director to save EPS figures
mkdir(dirpath(char(data_name)));

for num = 1:exm_num
    f = files(num);
    opts.file = strrep(f,'.mat','');
    alg = 0;
    data = get_data(opts.dataset, opts.file, "./Datasets");
    data = preprocess(opts.task, data, opts);
    opts.key_hpo = strcat("TC",num2str(opts.sample_ratio * 100),"_",opts.file);
    run_reduced();
end

%%
columnLabels = reshape([metrics; metrics+'-std'], [2*(NumIndexes+1), 1]);
if ~contains(opts.mode, 'search')
    matrix2latex(Avg_MatrixResults,strcat(opts.dataset, '_Avg_RR_Assessment.tex'), 'rowLabels',Alg_names,'columnLabels', ...
                 columnLabels,'alignment','c','format', struct("PSNR", "%.3f"));
    fprintf('\n')
    disp('#######################################################')
    disp(['Display the Avg/Std performance for:', num2str(1:exm_num)])
    disp('#######################################################')
    disp(' |====PSNR(Inf)====|====SSIM(1)====|====Q(1)====|===Q_avg(1)===|=====SAM(0)=====|======ERGAS(0)=======|=======CC(1)=======|=======SCC(1)=======|=======RMSE(0)=======')
    for i=1:length(Alg_names)
        fprintf("%s ", Alg_names{i});
        fprintf([ repmat('%.4f ',1,numel(Avg_MatrixResults(i, :))) '\n'], Avg_MatrixResults(i, :));
    end
else
    %% 搜索best结果的时候
    matrix2latex(Avg_MatrixResults,strcat(opts.dataset, '_Avg_RR_Assessment.tex'), 1, 'rowLabels',Alg_names,'columnLabels', ...
                 columnLabels,'alignment','c','format', struct("PSNR", "%.3f"));
    fprintf('\n')
    disp('#######################################################')
    disp(['Display the Avg/Std (search best) performance for:', num2str(1:exm_num)])
    disp('#######################################################')
    disp(' |====PSNR(Inf)====|====SSIM(1)====|====Times(0)====|')
    for i=1:length(Alg_names)
        fprintf("%s ", Alg_names{i});
        fprintf([ repmat('%.4f ',1,numel(Best_Avg_MatrixResults(i, :))) '\n'], Best_Avg_MatrixResults(i, :));
    end
end
fprintf('###################### Complete execution! ! !######################\n')
%%
titleImages = strrep(Alg_names,"_", "-");
left_col = ['', titleImages];
a = cat(1, columnLabels', Avg_MatrixResults);
total_multiexm = [left_col', a];

% clear Avg_MatrixResults total_multiexm PSNR_multiexm SSIM_multiexm SAM_multiexm
%% 

end