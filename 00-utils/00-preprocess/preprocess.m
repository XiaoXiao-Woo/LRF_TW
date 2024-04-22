function [corrupted, opt] = preprocess(task, data, opt)

%%
switch task
    case 'Fusion'
        rgb1 = hsi2rgb(data.hsi);
    case 'TC'
        corrupted = random_sampling(data, opt);
    case 'TC_initialization_M'
        fullpath = mfilename('fullpath'); 
        [path,~]=fileparts(fullpath);
        addpath([path, '/TC'])
        corrupted = gen_initialization_M(data, opt);
    case 'impulsive'
        corrupted = gen_noise(data, opt);
    case 'gaussian_impulsive_noise'
        [corrupted,opt] = gen_gaussian_impulsive_noise(data, opt);
    case 'poisson_noise'
        [corrupted,opt] = gen_possion_noise(data, opt);
    case 'possion_gaussian_noise'
        [corrupted,opt] = gen_possion_gaussian_noise(data, opt);
        
end
if isfield(opt, 't')
    switch opt.t
        case 'anscombe'
            [corrupted,opt] = gen_anscombe_transform(corrupted,opt);
    end
end

if ~exist('data') 
    disp(strcat(dataset_name, ' is not supported')); 
end

field = fieldnames(data); % cell
for i = 1:length(field)
    name_i = field{i};
    disp([strcat(name_i, " shape: "), size(data.(name_i))]);
end

end

function [data] = random_sampling(data, opt)
    % Sampling with random position
%     rng(1, 'twister');
    rand('seed',2);
    fprintf('=== The sample ratio is %4.2f ===\n', opt.sample_ratio);
    F = data.I_GT;
    Nway = size(data.I_GT);
    % 方法1
%     P = round(opt.sample_ratio*prod(Nway));  
%     Known = randsample(prod(Nway),P);
%     [Known,~] = sort(Known);
%     Xkn          = data.X(Known);
%     corrupted        = zeros(Nway);
%     corrupted(Known) = Xkn;
%     data.corrupted = corrupted;
    
    Omega  = find(rand(prod(Nway),1)<opt.sample_ratio);
    noise2 = zeros(Nway);
    noise2(Omega) = 1;
    data.corrupted = F.*noise2;
	data.mask2 = noise2;
    data.Omega = Omega;
    data.Re_tensor = F;
    % 方法3
%     Omega = randperm(prod(Nway));
%     Omega = Omega(1:round(opt.sample_ratio*prod(Nway)));
%     noise3 = zeros(Nway);
%     noise3(Omega) = 1;
%     data.corrupted = data.X.*noise3;
%     data.mask = noise;
    % 对比随机函数不同导致的噪声情况
%     noise1 = zeros(Nway);
%     noise1(Known) = 1;
%     data.mask1 = noise1;
%     data.mask2 = noise2;
%     sum(abs(noise2(:)-noise(:)))
%     sum(abs(noise1(:)-noise(:)))
%     sum(abs(noise2(:)-noise1(:)))
end

function [data] = gen_initialization_M(data, opt)
%     rng(1, 'twister'); %  rand('seed',2);
    fprintf('### Performing SR: %4.2f ###\n', opt.sample_ratio);
    Nway = size(data.Xtrue);
    rand('seed', 2);
    Omega = find(rand(prod(Nway),1)<opt.sample_ratio);
    Y_init = initialization_M(Nway, Omega, data.Xtrue(Omega));
%     sum(Y_init(:)), sum(data.Xtrue(:))
    noise = zeros(Nway);
    noise(Omega) = 1;
    F = zeros(Nway);
    F(Omega) = data.Xtrue(Omega);
    data.Re_tensor = F;
    data.corrupted = Y_init;
    data.mask = Y_init - data.Xtrue;
    data.Omega = Omega;
end

function [data] = gen_noise(data, opt)
    rng(1, 'twister'); %rand('seed',2);
    fprintf('=== The sample ratio is %4.2f ===\n', opt.sample_ratio);
    % corrupted by uniform distributed values
    data.corrupted = imnoise(data.X,'salt & pepper',opt.sample_ratio);
    data.mask= data.corrupted - data.X;
end

function [data, opt] = gen_gaussian_impulsive_noise(data, opt)
    Nway = size(data.X);
    sigma_n3=0.1*rand(Nway(3),1)+0.05;  % Gaussian noise
    sigma= mean(sigma_n3);
    p_n3=0.2*rand(Nway(3),1)+0.1;  % salt and pepper noise
    p= mean(p_n3);
    fprintf('=== The Gaussian noise level is  %4.3f ===\n', sigma);
    fprintf('=== The impulsive noise level is %4.3f ===\n', p);
    for j=1:Nway(3)
        Y_init(:,:,j) = imnoise(data.X(:,:,j),'salt & pepper',p_n3(j))+sigma_n3(j)*randn(Nway(1),Nway(2));
    end
    data.corrupted = Y_init;
    data.mask = Y_init - data.X;
end

function [data, opt] = gen_possion_noise(data, opt)
    %% Set noise level
    opt.kappa = 4;       % smaller kappa <--> heavier Poisson noise
    opt.sigma_ratio = 0.2;  % higher sigma_ratio <--> heavier Gaussian noise
    peak = 2^opt.kappa;               % expected peak value
    opt.sigma = peak * opt.sigma_ratio;     % sigma of Gaussian distribution
    data.corrupted = poissrnd(data.X * peak); % add Poisson noise
    data.mask = data.corrupted - data.X;
end

function [data, opt] = gen_possion_gaussian_noise(data, opt)
    %% Set noise level
    opt.kappa = 4;       % smaller kappa <--> heavier Poisson noise
    opt.sigma_ratio = 0.2;  % higher sigma_ratio <--> heavier Gaussian noise
    peak = 2^opt.kappa;               % expected peak value
    opt.sigma = peak * opt.sigma_ratio;     % sigma of Gaussian distribution
    noisy = poissrnd(data.X * peak); % add Poisson noise
    data.corrupted = noisy + opt.sigma * randn(size(data.X));  % add Gaussian noise
    data.mask = data.corrupted - data.X;
end

function [data, opt] = gen_anscombe_transform(data, opt)
    %% Apply VST (refer to TensorDL)
    fprintf('applying VST via anscombe transform\n');
    VST_msi = GenAnscombe_forward(data.corrupted, opt.sigma);    % VST via anscombe transform
    max_VST_msi = max(VST_msi(:));
    min_VST_msi = min(VST_msi(:));
    data.corrupted = (VST_msi - min_VST_msi) / (max_VST_msi - min_VST_msi);    % scale to [0, 1]
    opt.nsigma = 1 / (max_VST_msi - min_VST_msi); %VST_sigma
    opt.peak_value = 1;
end


function RGB = hsi2rgb(MS)
    sz = size(MS);
    sz = sz(1:end-1);
    R = [0.005 0.007 0.012 0.015 0.023 0.025 0.030 0.026 0.024 0.019 0.010 0.004 0     0      0    0     0     0     0     0     0     0     0     0     0     0     0     0    0     0       0
        0.000 0.000 0.000 0.000 0.000 0.001 0.002 0.003 0.005 0.007 0.012 0.013 0.015 0.016 0.017 0.02 0.013 0.011 0.009 0.005  0.001  0.001  0.001 0.001 0.001 0.001 0.001 0.001 0.002 0.002 0.003
        0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.001 0.003 0.010 0.012  0.013  0.022  0.020 0.020 0.018 0.017 0.016 0.016 0.014 0.014 0.013];
    R = R ./ sum(R, 2);
    R = R';
    R = R(:, [3 2 1]); %BGR2RGB
%     load('./True_CSR.mat')
    MS2 = reshape(MS,[sz*sz,31]);
    RGB = MS2*R;
    RGB = reshape(RGB,[sz,sz,3]);
end