function result = image2clbp(base_dir, picNum, options)
% image2clbp computes complete local binary pattern (CLBP) for graylevel images.
%
% Author: Wei Guo

    % genearte CLBP features
    patternMapping = getmapping(options.numNeighbor, 'uint8', options.mappingtype);
    
    % Create cell array for data from all subjects
    subject_data = cell(picNum,1);

    % Iterate over all subjects
    for i = 1:picNum
        file_name = sprintf('%s/images/%06d.ras', base_dir, i-1);
        Gray = imread(file_name);
        [m,n] = size(Gray);
        m_d = downsample(1:m, options.downsample_rate);
        n_d = downsample(1:n, options.downsample_rate);
        Gray = im2double(Gray(m_d,n_d));
        Gray = (Gray-mean(Gray(:)))/std(Gray(:))*20+128; % image normalization, to remove global intensity
        % compute CLBP
        [CLBP_S,CLBP_M,~] = clbp(Gray, options.radius, options.numNeighbor, patternMapping,'x');   
        subject_data{i}.clbp_s = CLBP_S;
        subject_data{i}.clbp_m = CLBP_M;
        subject_data{i}.file = file_name;

    end

    result.config.radius = options.radius;
    result.config.numNeighbor = options.numNeighbor;
    result.config.downsample_rate = options.downsample_rate;
    result.data = subject_data;
end


