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

Outex_H0 = cell(1,picNum);
for i = 1:picNum
    dipha_dst_file = fullfile(opt.src_dir, sprintf('clbp_s_%06d.diagram', i-1));
    [dim,b,d] = load_persistence_diagram(dipha_dst_file);
    data = [dim b d];
    Outex_H0{i} = data(dim==0, 2:3);
end

sig = 0.02;
res = 30;
rep = 100;
timerTrain = zeros(1, rep);
timerTest = zeros(1, rep);
test_ac_rep = zeros(1, rep);

Ncv = 10; % 10-fold cross validation
optionCV.stepSize = 4;
optionCV.bestLog2c = 8;
optionCV.bestLog2g = -6;
optionCV.epsilon = 0.001;
optionCV.Nlimit = 100;
optionCV.svmCmd = '-q'; % quiet mode

for k = 1:rep  
    tic 
    trainTxt = sprintf('%s/%03d/train.txt', rootpic, k-1);
    testTxt = sprintf('%s/%03d/test.txt', rootpic, k-1);
    [train, trainClass] = ReadOutexTxt(trainTxt);
    [test, testClass] = ReadOutexTxt(testTxt);

    %[H0_PIs] = make_PIs(Outex_H0, res, sig);
    [H0_PIs] = make_PIs(Outex_H0, res, sig, @arctan, 1);
    vec_H0_PIs = vecs_from_PIs(H0_PIs);
    mat_H0_PIs = cat(1, vec_H0_PIs{:})';
    
    [r_opt, ~, loc] = optimalMeasurements(mat_H0_PIs(:, train), 300);
    samples = loc(1:r_opt);

    [bestc, bestg, bestcv] = automaticParameterSelection(trainClass, ...
        mat_H0_PIs(samples, train)', Ncv, optionCV);
    
    cmd =['-c ', num2str(bestc), ' -g ', num2str(bestg)];
    model = ovrtrain(trainClass, mat_H0_PIs(samples, train)', cmd);
    timerTrain(k) = toc;
    [~, test_ac, ~] = ovrpredict(testClass, mat_H0_PIs(samples, test)', model);
    fprintf('testing accuracy = %g%%\n', test_ac * 100);
    test_ac_rep(k) = test_ac;
    timerTest(k) = toc;
end
 