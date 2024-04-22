function [data] = get_data(dataset_name, file_name, data_dir)

dataset_name = split(dataset_name, '_');
if length(dataset_name) == 2
    [dataset_name,frame] = deal(dataset_name{:});
else
    [dataset_name,frame, ~] = deal(dataset_name{:});
end
%%
switch dataset_name
    case 'CV'
        img = load(strcat(data_dir,'/video/CV/', frame, '/', file_name, '.mat')).X; %144x176x3x300
        if max(img(:))>1
        img = double(img)/255.0;
        end
        data.I_GT = img;
    case 'cave'%contains(dataset_name, ["balloons_ms", "chart_and_stuffed_toy_ms", "fake_and_real_tomatoes_ms"]) 
        hsi = load(strcat(data_dir,'/test_data/CAVE_test/', file_name, '.mat')).hsi;
        hsi = imresize(hsi, [256, 256], 'nearest');
        data.I_GT = hsi;
end

if exist('data', 'var') 
    field = fieldnames(data); % cell
    for i = 1:length(field)
        name_i = field{i};
        disp([strcat(name_i, " shape: "), size(data.(name_i))]);
    end
    return;
end

field = fieldnames(data); % cell
for i = 1:length(field)
    name_i = field{i};
    disp([strcat(name_i, " shape: "), size(data.(name_i))]);
end

end


