clear all; close all; clc

rootpic = '../../../data/Outex_TC_00000';
% picture number of the database
picNum = 480;

numClass = 24; rot = 20;
label = reshape(repmat(1:numClass, rot, 1), picNum,1);

% parameters
options.radius = 1;
options.numNeighbor = 8;
options.mappingtype = 'ri';
options.downsample_rate = 4;

opt.dst_dir = './clbp_s_output';
opt.src_dir = './clbp_s';
opt.label = 'clbp_s';
opt.dim = 0;

Outex_TC_00000 = image2clbp(rootpic, picNum, options);
pl_Outex_run_dipha(Outex_TC_00000, opt.label, opt.src_dir)

rep = 100;
timerTrain = zeros(1, rep);
timerTest = zeros(1, rep);
test_ac_rep = zeros(1, rep);

for k = 1:rep
    tic
    trainTxt = sprintf('%s/%03d/train.txt', rootpic, k-1);
    testTxt = sprintf('%s/%03d/test.txt', rootpic, k-1);
    [train, trainClass] = ReadOutexTxt(trainTxt);
    [test, testClass] = ReadOutexTxt(testTxt);
    
    [bestc, bestsig, bestcv, kernel] = automaticParameterSelection_Outex_kernel(Outex_TC_00000,...
        trainClass, train, 8, 0, 10, opt);
    
    cmd =['-c ', num2str(bestc), ' -t 4'];
    model = ovrtrain_kernel(trainClass, kernel(train,train), cmd);
    timerTrain(k) = toc;
    [~, test_ac, ~] = ovrpredict_kernel(testClass, kernel(test,train), model);
    fprintf('Accuracy = %g%%\n', test_ac * 100);
    timerTest(k) = toc;
    test_ac_rep(k) = test_ac;
    delete(fullfile(opt.dst_dir,'*.txt'));
end
   
