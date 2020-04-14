clear all; close all; clc

% preprocess the raw data
% subjects = write_SHREC_subjects('../../../data/SHREC14/Real/Data/SHREC14_real.txt');
% SHREC_real = mesh2hks('../../../data/SHREC14/Real/Data', subjects, 300);
subjects = write_SHREC_subjects('../../../data/SHREC14/Synthetic/Data/SHREC14_synthetic.txt');
SHREC_synthetic = mesh2hks('../../../data/SHREC14/Synthetic/Data', subjects, 300);

save('./SHREC_synthetic.mat','SHREC_synthetic','-v7.3');

% generate persistance diagrams for each subject at ti
% pl_SHREC_run_dipha('SHREC_real.mat', 'SHREC_real', 'real', './real')
pl_SHREC_run_dipha('./SHREC_synthetic.mat', 'SHREC_synthetic', 'syn', './synthetic')

numClass = 15; pose = 20;
total = numClass*pose;
label = reshape(repmat(1:numClass, pose, 1), total,1);

opt.dst_dir = './synthetic_output';
opt.src_dir = './synthetic';
opt.label = 'syn';
% opt.dst_dir = './real_output';
% opt.src_dir = './real';
% opt.label = 'real';
opt.dim = 1;
HKStime = 9;

rep = 30;
timerTrain = zeros(1, rep);
test_ac_rep = zeros(1, rep);

Ncv = 10; % 10-fold cross validation
optionCV.stepSize = 4;
optionCV.c = 2^6;
optionCV.sigma = 2^2;
optionCV.epsilon = 0.001;
optionCV.Nlimit = 50;
optionCV.svmCmd = '-q'; % quiet mode

rng(5)
for k=1:rep
    tic
    train = randsample(1:total, total*0.7); % Indices of diagrams used for training
    test = setdiff(1:total,train);  % Indices of diagrams used for testing
    trainClass = label(train);
    testClass = label(test);
    
    % [bestc, bestsig, bestcv, kernel] = SHREC_automaticParameterSelection(SHREC_synthetic, ...
    %    2, label, train, 8, -2, 10, opt);
    [bestc, bestsig, bestcv, kernel] = automaticParameterSelection_SHREC_kernel(SHREC_real, ...
                                        HKStime, trainClass, train, Ncv, optionCV, opt);
    cmd =['-c ', num2str(bestc), ' -t 4'];
    model = ovrtrain_kernel(trainClass, kernel(train,train), cmd);
    timerTrain(k) = toc;
    [~, test_ac, ~] = ovrpredict_kernel(testClass, kernel(test,train), model);
    fprintf('Accuracy = %g%%\n', test_ac * 100);
    test_ac_rep(k) = test_ac;
    delete(fullfile(opt.dst_dir,'*.txt'));
end
    


