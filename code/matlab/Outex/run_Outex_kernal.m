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

opt.dst_dir = './clbp_s_output'; % store kernel files
opt.src_dir = './clbp_s';
opt.label = 'clbp_s';
opt.dim = 0; % 0-dimensional PD

% compute CLBP for each image
Outex_TC_00000 = image2clbp(root, total, options);
% generate persistance diagrams for each image
pl_Outex_run_dipha(Outex_TC_00000, opt.label, opt.src_dir)

rep = 100;
timerTrain = zeros(1, rep);
test_ac_rep = zeros(1, rep);

% parameters of the grid search for CV
Ncv = 10; % 10-fold cross validation
optionCV.stepSize = 4;
optionCV.c = 2^8;        % initial C
optionCV.gamma = 2^0;    % initial gamma
optionCV.epsilon = 0.001;
optionCV.Nlimit = 50;
optionCV.svmCmd = '-q';  % quiet mode

for k = 1:rep
    tic
    trainTxt = sprintf('%s/%03d/train.txt', root, k-1);
    testTxt = sprintf('%s/%03d/test.txt', root, k-1);
    [train, trainClass] = ReadOutexTxt(trainTxt);
    [test, testClass] = ReadOutexTxt(testTxt);

    % grid search for best C and gamma
    [bestc, bestsig, bestcv, kernel] = automaticParameterSelection_Outex_kernel(Outex_TC_00000,...
        trainClass, train, Ncv, optionCV, opt);
    
    cmd =['-c ', num2str(bestc), ' -t 4'];
    model = ovrtrain_kernel(trainClass, kernel(train,train), cmd);
    timerTrain(k) = toc;
    [~, test_ac, ~] = ovrpredict_kernel(testClass, kernel(test,train), model);
    fprintf('Accuracy = %g%%\n', test_ac * 100);
    test_ac_rep(k) = test_ac;
    delete(fullfile(opt.dst_dir,'*.txt')); % delete existing kernel files for the next run
end
   
