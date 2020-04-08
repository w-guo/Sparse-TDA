clear all; close all; clc

% preprocess the raw data
subjects = write_SHREC_subjects('../../../data/SHREC14/Real/Data/SHREC14_real.txt');
SHREC_real = mesh2hks('../../../data/SHREC14/Real/Data', subjects, 1000);
% subjects = write_SHREC_subjects('../../../data/SHREC14/Synthetic/Data/SHREC14_synthetic.txt');

% generate persistance diagrams for each subject at ti
% pl_SHREC_run_dipha('SHREC_real_8.mat', 'SHREC_real', 'real', './real_8')
pl_SHREC_run_dipha('./SHREC/SHREC_synthetic_5.mat', 'SHREC_synthetic', 'syn', './synthetic_5')

numClass= 15; pose = 20;
%numClass= 40; pose = 10;
total = numClass*pose;
label = reshape(repmat(1:numClass, pose, 1), total,1);

SHREC_H1 = cell(1,total);
out_dir = './synthetic_5';
%out_dir = './real_8';
for i =1:total
    %dipha_dst_file = fullfile(out_dir, sprintf('real_%d_009.diagram', i-1));
    dipha_dst_file = fullfile(out_dir, sprintf('syn_%d_007.diagram', i-1));
    [dim,b,d] = load_persistence_diagram( dipha_dst_file );
    data = [dim b d];
    SHREC_H1{i} = data( dim==1, 2:3 );
end

sig = 0.0001;
%sig = 0.15;
res = 30;
rep = 30;
timerTrain = zeros(1, rep);
timerTest = zeros(1, rep);
test_ac_rep = zeros(1, rep);

Ncv = 10; % 10-fold cross validation
optionCV.stepSize = 4;
optionCV.bestLog2c = 6;
optionCV.bestLog2g = 2;
optionCV.epsilon = 0.001;
optionCV.Nlimit = 50;
optionCV.svmCmd = '-q'; % quiet mode

rng(5);
for k = 1:rep
    tic
    train = randsample(1:total, total*0.7); % Indices of diagrams used for training
    test = setdiff(1:total,train);  % Indices of diagrams used for testing

    %[H1_PIs] = make_PIs(SHREC_H1, res, sig); % apply linear weight function
    [H1_PIs] = make_PIs(SHREC_H1, res, sig, @arctan, 1); % apply nonlinear weight function
    vec_H1_PIs = vecs_from_PIs(H1_PIs);
    mat_H1_PIs = cat(1, vec_H1_PIs{:})';
    
    [r_opt, ~, loc] = optimalMeasurements(mat_H1_PIs(:, train), 180); 
    samples = loc(1:r_opt);

    [bestc, bestg, bestcv] = automaticParameterSelection_sparse(label(train), ...
        mat_H1_PIs(samples, train)', Ncv, optionCV);
    
    cmd = ['-c ', num2str(bestc), ' -g ', num2str(bestg)];
    model = ovrtrain(label(train), mat_H1_PIs(samples, train)', cmd);
    timerTrain(k) = toc;
    [~, test_ac, ~] = ovrpredict(label(test), mat_H1_PIs(samples, test)', model);
    fprintf('Accuracy = %g%%\n', test_ac * 100);
    test_ac_rep(k) = test_ac;
    timerTest(k) = toc;
end

