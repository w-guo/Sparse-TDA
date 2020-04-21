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
opt.dst_dir = './synthetic_output';
opt.src_dir = './synthetic';
opt.label = 'synthetic';
% opt.dst_dir = './real_output';
% opt.src_dir = './real';
% opt.label = 'real';
opt.dim = 1;

% generate persistance diagrams for each subject at ti
pl_SHREC_run_dipha(mat_file, 'SHREC', opt.label, opt.src_dir);

numClass = 15; pose = 20; % synthetic
% numClass= 40; pose = 10; % real
total = numClass * pose;
label = reshape(repmat(1:numClass, pose, 1), total, 1);

% choose the best hks time scale for simulation
HKStime = 9;

rep = 30;
timerTrain = zeros(1, rep);
test_ac_rep = zeros(1, rep);

Ncv = 10; % 10-fold cross validation
optionCV.stepSize = 4;
optionCV.c = 2^6;       % initial C
optionCV.sigma = 2^2;   % initial sigma
optionCV.epsilon = 0.001;
optionCV.Nlimit = 50;
optionCV.svmCmd = '-q'; % quiet mode

rng(5)
for k = 1:rep
    tic
    train = randsample(1:total, total * 0.7); % Indices of diagrams used for training
    test = setdiff(1:total,train);  % Indices of diagrams used for testing
    trainClass = label(train);
    testClass = label(test);
    
    % grid search for best C and sigma
    [bestc, bestsig, bestcv, kernel] = automaticParameterSelection_SHREC_kernel(SHREC, ...
                                        HKStime, trainClass, train, Ncv, optionCV, opt);
    cmd =['-c ', num2str(bestc), ' -t 4'];
    model = ovrtrain_kernel(trainClass, kernel(train,train), cmd);
    timerTrain(k) = toc;
    [~, test_ac, ~] = ovrpredict_kernel(testClass, kernel(test,train), model);
    fprintf('Accuracy = %g%%\n', test_ac * 100);
    test_ac_rep(k) = test_ac;
    delete(fullfile(opt.dst_dir,'*.txt'));
end
    


