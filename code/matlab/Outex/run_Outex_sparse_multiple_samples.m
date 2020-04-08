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
for i =1:picNum
    dipha_dst_file = fullfile(opt.src_dir, sprintf('clbp_s_%06d.diagram', i-1));
    [dim,b,d] = load_persistence_diagram(dipha_dst_file);
    data = [dim b d];
    Outex_H0{i} = data(dim==0, 2:3);
end

sig = 0.02;
res = 30;
rep = 30;
increm = -80:20:-20;
s_num = length(increm);
preTrain = zeros(1, rep);
timerTrain = zeros(s_num, rep);
timerTest = zeros(s_num, rep);
test_ac_rep = zeros(s_num, rep);
r_opt_rep = zeros(1, rep);
energy_p_rep = zeros(s_num, rep);

Ncv = 10; % 10-fold cross validation
optionCV.stepSize = 4;
optionCV.bestLog2c = 8;
optionCV.bestLog2g = -6;
optionCV.epsilon = 0.001;
optionCV.Nlimit = 100;
optionCV.svmCmd = '-q'; % quiet mode

rng(5)
for k = 1:rep
    tic
    train = randsample(1:picNum, picNum*0.7); % Indices of diagrams used for training
    test = setdiff(1:picNum,train);  % Indices of diagrams used for testing
    trainClass = label(train);
    testClass = label(test);
    
    %[H0_PIs] = make_PIs(Outex_H0, res, sig); 
    [H0_PIs] = make_PIs(Outex_H0, res, sig, @arctan, 1);
    vec_H0_PIs = vecs_from_PIs(H0_PIs);
    mat_H0_PIs = cat(1, vec_H0_PIs{:})';
    
    [U, r_opt, energy] = optimalRankTrunc(mat_H0_PIs(:, train));
    r_opt_rep(k) = r_opt;
    S = r_opt + increm;   
    preTrain(k) = toc;
    for i = 1:s_num
        tic
        energy_p_rep(i, k) = energy(S(i));
        loc = optimalPlacements(U, r_opt, S(i));
        
        [bestc, bestg, bestcv] = automaticParameterSelection_sparse(trainClass, ...
            mat_H0_PIs(loc, train)', Ncv, optionCV);
        
        cmd =['-c ', num2str(bestc), ' -g ', num2str(bestg)];
        model = ovrtrain(trainClass, mat_H0_PIs(loc, train)', cmd);
        timerTrain(i, k) = toc;
        [~, test_ac, ~] = ovrpredict(testClass, mat_H0_PIs(loc, test)', model);
        fprintf('testing accuracy = %g%%\n', test_ac * 100);
        test_ac_rep(i, k) = test_ac;
        timerTest(i, k) = toc;
    end
end
