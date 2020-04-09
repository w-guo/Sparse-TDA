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

opt.src_dir = './clbp_s';
opt.label = 'clbp_s';
opt.dim = 0; % 0-dimensional PD

% compute CLBP for each image
Outex_TC_00000 = image2clbp(root, total, options);
% generate persistance diagrams for each image
pl_Outex_run_dipha(Outex_TC_00000, opt.label, opt.src_dir)

Outex_H0 = cell(1,total);
for i = 1:total
    dipha_dst_file = fullfile(opt.src_dir, sprintf('clbp_s_%06d.diagram', i-1));
    [dim,b,d] = load_persistence_diagram(dipha_dst_file);
    data = [dim b d];
    Outex_H0{i} = data(dim==0, 2:3);
end

sig = 0.02;
res = 30;
rep = 30;
increm = -80:40:80;
s_num = length(increm);
preTrain = zeros(1, rep);
timerTrain = zeros(s_num, rep);
test_ac_rep = zeros(s_num, rep);
r_opt_rep = zeros(1, rep);
energy_p_rep = zeros(s_num, rep);

% parameters of the grid search for CV
Ncv = 10; % 10-fold cross validation
optionCV.stepSize = 4;
optionCV.c = 2^8;        % initial C
optionCV.gamma = 2^(-6); % initial gamma
optionCV.epsilon = 0.001;
optionCV.Nlimit = 50;
optionCV.svmCmd = '-q';  % quiet mode

rng(5)
for k = 1:rep
    tic
    train = randsample(1:total, total * 0.7); % Indices of diagrams used for training
    test = setdiff(1:total, train);  % Indices of diagrams used for testing
    trainClass = label(train);
    testClass = label(test);
    
    %[H0_PIs] = make_PIs(Outex_H0, res, sig); % apply linear weighting function
    [H0_PIs] = make_PIs(Outex_H0, res, sig, @arctan, 1); % apply nonlinear weighting function
    vec_H0_PIs = vecs_from_PIs(H0_PIs);
    mat_H0_PIs = cat(1, vec_H0_PIs{:})';
    
    % compute optimal rank truncation
    [U, r_opt, energy] = optimalRankTrunc(mat_H0_PIs(:, train));
    r_opt_rep(k) = r_opt;
    S = r_opt + increm;   
    preTrain(k) = toc;
    for i = 1:s_num
        tic
        energy_p_rep(i, k) = energy(S(i));
        % compute optimal locations based on required no. of pixel samples 
        loc = optimalPlacements(U, r_opt, S(i));

        % grid search for best C and gamma
        [bestc, bestg, bestcv] = automaticParameterSelection_sparse(trainClass, ...
            mat_H0_PIs(loc, train)', Ncv, optionCV);
        
        cmd =['-c ', num2str(bestc), ' -g ', num2str(bestg)];
        model = ovrtrain(trainClass, mat_H0_PIs(loc, train)', cmd);
        timerTrain(i, k) = toc;
        [~, test_ac, ~] = ovrpredict(testClass, mat_H0_PIs(loc, test)', model);
        fprintf('testing accuracy = %g%%\n', test_ac * 100);
        test_ac_rep(i, k) = test_ac;
    end
end
