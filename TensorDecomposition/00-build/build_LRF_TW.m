function [Re_tensor,alg_save_dir,best_alg_params] = build_TWLRF(data, mode, opts)%%
addpath('inc_TW_TC');
%%
fprintf('\n');
% initialization of the parameters
% Please refer to our manuscript to set the parameters
opts.tol   = 1e-5;
opts.maxit = 1000;
opts.rho   = 1e-3;%0.001;

opts.rho_max=1e2;
opts.mu = 1.015;
opts.rho_nm = 0.5; % 1e-1~1e0 penalty
opts.lamda_nm = 1; % set 0 to TW
opts.lamda = 5;% usually 1~10
opts.lamda_c = 0;
opts.flag_rank_inc = 0;

% opts.rho_max=1e2;
% opts.mu = 1.2;
% opts.rho_nm = 0.1; % 1e-1~1e0 penalty
% opts.lamda_nm = 1; % set 0 to TW
% opts.lamda = 1;% usually 1~10
% opts.lamda_c = 0;

%MSI: R3=L1=L2,R1=L3
%R1 = {3, 4, 5}, R2={10, 15, 20, 25} R3={2, 3},
R = [3, 10, 2; % R_i
    2, 2,3]; % L_i
opts.max_R = R;
function [opts] = get_keyhpo(opts)
    value = opts.Rs.(opts.key_hpo);%getfield(opts.Rs, opts.key_hpo);
    opts.rho = value.('rho');
    opts.rho_nm = value.('rho_nm');
    opts.R = value.('R');
    opts.max_R = opts.R;
%     opts.lamda = value.('lamda');
end
if ~isfield(opts, 'key_hpo')
    opts.R = R;
else
    opts.get_keyhpo = @get_keyhpo;
    opts.Rs = struct("TC20_balloons_ms", struct('R',[5, 25, 3;3, 3, 5],'rho', 1e-5, 'rho_nm', 1), ...
                    "TC20_cd_ms",struct('R',[5, 25, 3; 3, 3, 5],'rho', 1e-3, 'rho_nm', 0.3), ...
                    "TC20_chart_and_stuffed_toy_ms",struct('R',[5, 25, 3; 3, 3, 5],'rho', 1e-3, 'rho_nm', 0.6), ...
                    "TC20_clay_ms",struct('R',[3, 25, 3; 3, 3, 3],'rho', 1e-3, 'rho_nm', 0.5), ...
                    "TC20_fake_and_real_beers_ms",struct('R',[4, 25, 3; 3, 3, 4],'rho', 1e-3, 'rho_nm', 0.5), ...
                    "TC20_fake_and_real_lemon_slices_ms",struct('R',[5, 25, 3; 3, 3, 5],'rho', 1e-4, 'rho_nm', 1), ...
                    "TC20_fake_and_real_tomatoes_ms",struct('R',[3, 25, 3; 3, 3, 3],'rho', 1e-3, 'rho_nm', 0.5), ...
                    "TC20_feathers_ms",struct('R',[5, 25, 3; 3, 3, 5],'rho', 1e-5, 'rho_nm', 0.1), ...
                    "TC20_flowers_ms",struct('R',[5, 25, 3; 3, 3, 5],'rho', 1e-5, 'rho_nm', 0.3), ...
                    "TC20_hairs_ms",struct('R',[5, 25, 3; 3, 3, 5],'rho', 1e-3, 'rho_nm', 0.5), ...
                    "TC20_jelly_beans_ms", struct('R',[5, 25, 3; 3, 3, 5],'rho', 1e-5, 'rho_nm', 0.8), ...
                    "TC10_balloons_ms", struct('R',[5, 25, 3;3, 3, 5],'rho', 1e-3, 'rho_nm', 0.5), ...
                    "TC10_cd_ms",struct('R',[5, 20, 3; 3, 3, 5],'rho', 1e-3, 'rho_nm', 0.5), ...
                    "TC10_chart_and_stuffed_toy_ms",struct('R',[5, 20, 3; 3, 3, 5],'rho', 1e-3, 'rho_nm', 0.5), ...
                    "TC10_clay_ms",struct('R',[3, 20, 3; 3, 3, 3],'rho', 1e-3, 'rho_nm', 0.5), ...
                    "TC10_fake_and_real_beers_ms",struct('R',[5, 20, 3; 3, 3, 5],'rho', 1e-3, 'rho_nm', 0.5), ...
                    "TC10_fake_and_real_lemon_slices_ms",struct('R',[5, 20, 3; 3, 3, 5],'rho', 1e-3, 'rho_nm', 0.5), ...
                    "TC10_fake_and_real_tomatoes_ms",struct('R',[5, 10, 3; 3, 3, 5],'rho', 1e-3, 'rho_nm', 0.5), ...
                    "TC10_feathers_ms",struct('R',[5, 25, 3; 3, 3, 5],'rho', 1e-3, 'rho_nm', 0.5), ...
                    "TC10_flowers_ms",struct('R',[4, 25, 3; 3, 3, 4],'rho', 1e-3, 'rho_nm', 0.5), ...
                    "TC10_hairs_ms",struct('R',[3, 10, 3; 3, 3, 3],'rho', 1e-3, 'rho_nm', 0.5), ...
                    "TC10_jelly_beans_ms", struct('R',[5, 25, 3; 3, 3, 5],'rho', 1e-3, 'rho_nm', 0.5),...
                    "TC5_balloons_ms", struct('R',[5, 25, 3;3, 3, 5],'rho', 1e-3, 'rho_nm', 0.5), ...
                    "TC5_cd_ms",struct('R',[5, 15, 3; 3, 3, 5],'rho', 1e-3, 'rho_nm', 0.5), ...
                    "TC5_chart_and_stuffed_toy_ms",struct('R',[5, 25, 3; 3, 3, 5],'rho', 1e-3, 'rho_nm', 0.5, 'lamda', 1), ...
                    "TC5_clay_ms",struct('R',[5, 25, 3; 3, 3, 5],'rho', 1e-3, 'rho_nm', 0.5), ...
                    "TC5_fake_and_real_beers_ms",struct('R',[4, 15, 3; 3, 3, 4],'rho', 1e-3, 'rho_nm', 0.5), ...
                    "TC5_fake_and_real_lemon_slices_ms",struct('R',[5, 15, 3; 3, 3, 5],'rho', 1e-3, 'rho_nm', 0.5), ...
                    "TC5_fake_and_real_tomatoes_ms",struct('R',[4, 25, 3; 3, 3, 4],'rho', 1e-3, 'rho_nm', 0.5), ...
                    "TC5_feathers_ms",struct('R',[5, 25, 3; 3, 3, 5],'rho', 1e-3, 'rho_nm', 0.5), ...
                    "TC5_flowers_ms",struct('R',[5, 25, 3; 3, 3, 5],'rho', 1e-3, 'rho_nm', 0.5), ...
                    "TC5_hairs_ms",struct('R',[3, 15, 3; 3, 3, 3],'rho', 1e-3, 'rho_nm', 0.5), ...
                    "TC5_jelly_beans_ms", struct('R',[4, 20, 3; 3, 3, 4],'rho', 1e-3, 'rho_nm', 0.5)...
                    );
end

%Video: R3=R4,L1=L2=L3=L4
% R1={2, 3, 4, 5}, R2={10, 15, 20, 25}, R3={3, 4, 5} and L1={2,3}
% opts.R = [3 15 3 3;
%           3 3 3 3];
%%
data.corrupted = initialization_M(size(data.I_GT), data.Omega, data.I_GT(data.Omega));

%% Common HPO Settings

function [opts] = set_hpo(opts, pair)
    [r1,r2,r3] = split_vec(pair);
    alg_name = strcat(opts.alg, "_r1_", num2str(r1),'_r2_',num2str(r2), '_r3_', num2str(r3));
    disp(['performing ',alg_name, ' ... ']);
    opts.R = [r1, r2, r3; % R_i
            r3, r3, r1]; % L_
    opts.max_R = opts.R;
end

opts.alg = "LRF_TW";
opts.save_params = ["R", "mu", "rho", "rho_nm", "max_R"];
opts.set_hpo = @set_hpo;
opts.model = @LRF_TW;
opts.func_m = opts.model;
opts.model_desc = "rank_inc_if";
fullpath = mfilename('fullpath');
opts.copy_list = [convertCharsToStrings(strcat(fullpath,'.m')), functions(opts.model).file];


%% gridSearch and save
pairs = [1];
if strcmp(mode, 'search_v2')
    rank1 = [2, 3, 4, 5];
    rank2 = [10, 15, 20, 25]; 
    rank3 = [2, 3, 4, 5]; %
    [rank1, rank2, rank3] = ndgrid(rank1,rank2, rank3);
%     只有[p,q] = meshgrid(param1,param2); pairs = [p(:) q(:)];
    pairs = [rank1(:), rank2(:), rank3(:)];
else
    opts
end
%%
[Re_tensor, alg_save_dir, best_alg_params] = search_runner(data, pairs, mode, opts, 1, -1);
%%
rmpath('inc_TW_TC');

end