function [bestc, bestsig, bestcv, kernel] = automaticParameterSelection_SHREC_kernel(X, ...
                HKStime, trainClass, train, Ncv, option, opt)
% This function assist you to obtain the cost parameter C and kernel scale 
% parameter sigma automatically.
%
% INPUT:
% X: A SHREC struct 
% HKStime: A scalar, HKStime = t means X.config.T1(t) is used to compute HKS
% trainClass: An vector denoting the class for each observation
% train: An vector denoting the indices of diagrams used for training
% Ncv: A scalar representing Ncv-fold cross validation for parameter
% selection. 
% option: options for parameters selecting
% opt: A struct with the following fields:
%       .src_dir            - Source directory where .diagram files reside
%       .dst_dir            - Destination directory where kernel files reside
%       .label              - e.g., real
%       .dim                - Homology dimension

% OUTPUT:
% bestc: A scalar denoting the best value for C
% bestsig: A scalar denoting the best value for sigma
% bestcv: the best accuracy calculated from the training data set
% kernel: a matrix denoting the kernel for the best model

% Modified from https://github.com/Abusamra/LIBSVM-multi-classification/blob/master/src/automaticParameterSelection.m

% #######################
% Automatic Cross Validation 
% Parameter selection using n-fold cross validation
% #######################

if nargin > 6
    stepSize = option.stepSize;
    bestLog2c = log2(option.c);
    bestLog2sig = log2(option.sigma);
    epsilon = option.epsilon;
    Nlimit = option.Nlimit;
    svmCmd = option.svmCmd;
else
    stepSize = 5;
    bestLog2c = 0;
    bestLog2sig = 0;
    epsilon = 0.005;
    Nlimit = 100;
    svmCmd = '';
end

% initial some auxiliary variables
bestcv = 0;
deltacv = 10^6;
cnt = 1;
breakLoop = 0;

while abs(deltacv) > epsilon && cnt < Nlimit
    bestcv_prev = bestcv;
    prevStepSize = stepSize;
    stepSize = prevStepSize/2;
    log2c_list = bestLog2c-prevStepSize: stepSize: bestLog2c+prevStepSize;
    log2sig_list = bestLog2sig-prevStepSize: stepSize: bestLog2sig+prevStepSize;
    
    numLog2c = length(log2c_list);
    numLog2sig = length(log2sig_list);
    
    for i = 1:numLog2c
        log2c = log2c_list(i);
        for j = 1:numLog2sig
            log2sig = log2sig_list(j);
            sig = 2^log2sig;
            
            % With some precal kernel
            scale_str = ['scale_' num2str(sig, '%e')];
            dim_str = ['dim_' num2str(opt.dim)];
            kernel_file = fullfile(opt.dst_dir, ...
                [...
                opt.label '_' ...               % e.g., real
                'K_inner_product' '_' ...       % IP kernel
                scale_str '_' ...               % PSS time (sigma)
                dim_str '.txt'                  % Hom.-dim.
                ]);
            % Avoid unnecessary recomputation
            if (exist(kernel_file, 'file' ) ~= 2)
                K = pl_SHREC_compute_kernel(X, HKStime, sig, opt);
            else
                tmp = load(kernel_file);
                K = pl_normalize_kernel(tmp);
            end
          
            cmd = ['-c ', num2str(2^log2c), ' -t 4', ' ', svmCmd];
            cv = get_cv_ac_kernel(trainClass, K(train,train), cmd, Ncv);
            if (cv >= bestcv)
                bestcv = cv; bestLog2c = log2c; bestLog2sig = log2sig;
                bestc = 2^bestLog2c; bestsig = 2^bestLog2sig; kernel = K;
            end
            disp(['So far, cnt=',num2str(cnt),' the best parameters, yielding Accuracy=',num2str(bestcv*100),'%, are: C=',num2str(bestc),', sigma=',num2str(bestsig)]);
            % Break out of the loop when the cnt is up to the condition
            if cnt >= Nlimit, breakLoop = 1; break; end
            cnt = cnt + 1;
        end
        if breakLoop == 1, break; end
    end
    if breakLoop == 1, break; end
    deltacv = bestcv - bestcv_prev;  
end
disp(['The best parameters, yielding Accuracy=',num2str(bestcv*100),'%, are: C=',num2str(bestc),', sigma=',num2str(bestsig)]);
