clear all; close all; clc

root = '../../../data/Outex_TC_00000';
% total number of images
numClass = 24; rot = 20;
total = numClass * rot;
label = reshape(repmat(1:numClass, rot, 1), total, 1);

% parameters for CLBP
options.radius = 1;
options.numNeighbor = 8;
options.mappingtype = 'ri';
options.downsample_rate = 4;

% compute CLBP for each image
Outex = image2clbp(root, total, options);

% options for persistence diagrams
opt.src_dir = './clbp_s';
opt.label = 'clbp_s';
opt.dim = 0; % 0-dimensional PD

% generate persistance diagrams for each image
pl_Outex_run_dipha(Outex, opt.label, opt.src_dir)

% extract birth and death times from each persistance diagram
Outex_H0 = cell(1,total);
for i = 1:total
    dipha_dst_file = fullfile(opt.src_dir, sprintf('clbp_s_%06d.diagram', i-1));
    [dim,b,d] = load_persistence_diagram(dipha_dst_file);
    data = [dim b d];
    Outex_H0{i} = data(dim==opt.dim, 2:3);
end

sig = 0.02;
res = 30;
rep = 100;
timerTrain = zeros(1, rep);
test_ac_rep = zeros(1, rep);

% parameters of the grid search for CV
Ncv = 10; % 10-fold cross validation
optionCV.stepSize = 4;
optionCV.c = 2^8;        % initial C
optionCV.gamma = 2^(-6); % initial gamma
optionCV.epsilon = 0.001;
optionCV.Nlimit = 50;
optionCV.svmCmd = '-q';  % quiet mode

for k = 1:rep  
    tic 
    trainTxt = sprintf('%s/%03d/train.txt', root, k-1);
    testTxt = sprintf('%s/%03d/test.txt', root, k-1);
    [train, trainClass] = ReadOutexTxt(trainTxt);
    [test, testClass] = ReadOutexTxt(testTxt);

    % generate persistence images
    % [H0_PIs] = make_PIs(Outex_H0, res, sig); % apply linear weighting function
    [H0_PIs] = make_PIs(Outex_H0, res, sig, @arctan, 1); % apply nonlinear weighting function
    vec_H0_PIs = vecs_from_PIs(H0_PIs); % vectorize each PI into a column
    mat_H0_PIs = cat(1, vec_H0_PIs{:})'; % stack all PIs into a matrix
    
    % compute optimized sparse samples
    [r_opt, ~, loc] = optimalMeasurements(mat_H0_PIs(:, train), 300);
    samples = loc(1:r_opt);

    % grid search for best C and gamma
    [bestc, bestg, bestcv] = automaticParameterSelection(trainClass, ...
                                mat_H0_PIs(samples, train)', Ncv, optionCV);
    
    cmd = ['-c ', num2str(bestc), ' -g ', num2str(bestg)];
    model = ovrtrain(trainClass, mat_H0_PIs(samples, train)', cmd); 
    timerTrain(k) = toc;
    [~, test_ac, ~] = ovrpredict(testClass, mat_H0_PIs(samples, test)', model);
    fprintf('testing accuracy = %g%%\n', test_ac * 100);
    test_ac_rep(k) = test_ac;
end
 