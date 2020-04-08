clear all; close all; clc

% preprocess the raw data
% subjects = write_SHREC_subjects('../../../data/SHREC14/Real/Data/SHREC14_real.txt');
% SHREC_real = mesh2hks('../../../data/SHREC14/Real/Data', subjects, 300);
subjects = write_SHREC_subjects('../../../data/SHREC14/Synthetic/Data/SHREC14_synthetic.txt');
SHREC_synthetic = mesh2hks('../../../data/SHREC14/Synthetic/Data', subjects, 300);

save('./SHREC_synthetic_5.mat','SHREC_synthetic','-v7.3');

% generate persistance diagrams for each subject at ti
% pl_SHREC_run_dipha('SHREC_real_8.mat', 'SHREC_real', 'real', './real_8')
pl_SHREC_run_dipha('./SHREC_synthetic_5.mat', 'SHREC_synthetic', 'syn', './synthetic_5')

numClass = 15; pose = 20;
total = numClass*pose;
label = reshape(repmat(1:numClass, pose, 1), total,1);

opt.dst_dir = './synthetic_output';
opt.src_dir = './synthetic_5';
opt.label = 'syn';
% opt.dst_dir = './real_output';
% opt.src_dir = './real_8';
% opt.label = 'real';
opt.dim = 1;

rep = 30;
timerTrain = zeros(1, rep);
timerTest = zeros(1, rep);
test_ac_rep = zeros(1, rep);

p=[0.5 0.6 0.8 0.9];
for j=1:4
    rng(5)
    for k=1:rep
        tic
        train = randsample(1:total, total*p(j)); % Indices of diagrams used for training
        test = setdiff(1:total,train);  % Indices of diagrams used for testing
        
        [bestc, bestsig, bestcv, kernel] = SHREC_automaticParameterSelection(SHREC_synthetic, ...
            2, label, train, 8, -2, 10, opt);
        %     [bestc, bestsig, bestcv, kernel] = SHREC_automaticParameterSelection(SHREC_real, ...
        %                                         9, label, train, 6, -12, 10, opt);
        cmd =['-c ', num2str(bestc), ' -t 4'];
        model = ovrtrain_kernel(label(train), kernel(train,train), cmd);
        timerTrain(k) = toc;
        [~, test_ac, ~] = ovrpredict_kernel(label(test), kernel(test,train), model);
        fprintf('Accuracy = %g%%\n', test_ac * 100);
        test_ac_rep(k) = test_ac;
        timerTest(k)=toc;
        delete(fullfile(opt.dst_dir,'*.txt'));
    end
    save(strcat('SHREC_syn_kernal_',num2str(p(j)*100),num2str(100-p(j)*100),'.mat'), 'test_ac_rep', 'timerTrain', 'timerTest')
end

