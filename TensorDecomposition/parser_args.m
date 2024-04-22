
Algorithms = struct("LRF_TW", @build_LRF_TW);


%% Show result
location3  = [10 50 45 85];
location4 = [];
range_bar = [0, 0.2];
data_name = strcat('3_EPS/', opts.dataset, '/', opts.dataset, '_');  % director to save EPS figures

A_num = length(Algorithms);
Re_tensor = cell(A_num,1);
NumIndexes = 9;
MatrixResults = zeros(A_num, NumIndexes);
MatrixTimes = zeros(A_num, 1);
