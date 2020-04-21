clear all; close all; clc

subfolder = 'Synthetic';
filename = 'SHREC_synthetic';
% subfolder = 'Real';
% filename = 'SHREC_real';

% save the preprocessed meshes as a mat file in the current directory to
% avoid unnecessary recomputation during each run
mat_file = fullfile([filename, '.mat']);
if (exist(mat_file, 'file') ~= 2)
    % preprocess the raw data
    root = fullfile('../../../data/SHREC14/', subfolder, '/Data');
    list_file = fullfile(root, [filename, '.txt']);
    if (exist(list_file, 'file') ~= 2)
        obj_files = dir(fullfile(root, '*.obj'));
        fid = fopen(list_file, 'w');
        fprintf(fid, '%s\n', obj_files.name);
        fclose(fid);
    end
    subjects = write_SHREC_subjects(list_file);
    SHREC = mesh2hks(root, subjects, 1000);
    save(mat_file, 'SHREC', '-v7.3');
end

% options for persistence diagrams
opt.src_dir = './synthetic';
opt.label = 'synthetic';
% opt.src_dir = './real';
% opt.label = 'real'
opt.dim = 1;

% generate persistance diagrams for each subject at ti
pl_SHREC_run_dipha(mat_file, 'SHREC', opt.label, opt.src_dir);

numClass= 15; pose = 20; % synthetic
% numClass= 40; pose = 10; % real
total = numClass * pose;
label = reshape(repmat(1:numClass, pose, 1), total, 1);

% choose the best hks time scale for simulation
HKStime = 7; % synthetic
% HKStime = 9; % real

% extract birth and death times from each persistance diagram
SHREC_H1 = cell(1,total);
for i = 1:total
    dipha_dst_file = fullfile(opt.src_dir, [opt.label, '_', ...
                    num2str(i-1, '%d'), '_', num2str(HKStime, '%.3d'), '.diagram']);
    [dim,b,d] = load_persistence_diagram( dipha_dst_file );
    data = [dim b d];
    SHREC_H1{i} = data( dim==opt.dim, 2:3 );
end

sig = 0.2; % synthetic
% sig = 0.0001; % real
res = 30;
rep = 30;
timerTrain = zeros(1, rep);
test_ac_rep = zeros(1, rep);

% parameters of the grid search for CV
Ncv = 10; % 10-fold cross validation
optionCV.stepSize = 4;
optionCV.c = 2^6;       % initial C
optionCV.gamma = 2^2;   % initial gamma
optionCV.epsilon = 0.001;
optionCV.Nlimit = 100;
optionCV.svmCmd = '-q'; % quiet mode

rng(5);
for k = 1:rep
    tic
    train = randsample(1:total, total * 0.7); % Indices of diagrams used for training
    test = setdiff(1:total,train);  % Indices of diagrams used for testing
    trainClass = label(train);
    testClass = label(test);
    
    % generate persistence images
    % [H1_PIs] = make_PIs(SHREC_H1, res, sig); % apply linear weight function
    [H1_PIs] = make_PIs(SHREC_H1, res, sig, @arctan, 1); % apply nonlinear weight function
    vec_H1_PIs = vecs_from_PIs(H1_PIs);
    mat_H1_PIs = cat(1, vec_H1_PIs{:})';

    % compute optimized sparse samples
    [r_opt, ~, loc] = optimalMeasurements(mat_H1_PIs(:, train), 180); 
    samples = loc(1:r_opt);

    % grid search for best C and gamma
    [bestc, bestg, bestcv] = automaticParameterSelection(trainClass, ...
                                mat_H1_PIs(samples, train)', Ncv, optionCV);
    
    cmd = ['-c ', num2str(bestc), ' -g ', num2str(bestg)];
    model = ovrtrain(trainClass, mat_H1_PIs(samples, train)', cmd);
    timerTrain(k) = toc;
    [~, test_ac, ~] = ovrpredict(testClass, mat_H1_PIs(samples, test)', model);
    fprintf('Accuracy = %g%%\n', test_ac * 100);
    test_ac_rep(k) = test_ac;
end

