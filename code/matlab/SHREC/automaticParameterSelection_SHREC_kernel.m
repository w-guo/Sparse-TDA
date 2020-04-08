function [bestc, bestsig, bestcv, kernel] = automaticParameterSelection(X, ...
                HKStime, label, train, bestLog2c, bestLog2sig, Ncv, options)
% This function assist you to obtain the cost parameter C  and kernel scale 
% parameter Sigma automatically.
%
% INPUT:
% bestLog2c: initial value for bestLog2c
% bestLog2sig: initial value for bestLog2sig
% Ncv: A scalar representing Ncv-fold cross validation for parameter
% selection. Note that this function does not require the user to specify
% the run number for each iteration because it automatically assigns the run
% number in the code "get_cv_ac.m".

% OUTPUT:
% bestc: A scalar denoting the best value for C
% bestsig: A scalar denoting the best value for sigma
% bestcv: the best accuracy calculated from the training data set

% #######################
% Automatic Cross Validation 
% Parameter selection using n-fold cross validation
% #######################

stepSize = 4;
epsilon = 0.001;
Nlimit = 50;

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
            % With some kernel
            % cmd = ['-q -c ', num2str(2^log2c), ' -g ', num2str(2^log2sig),' -t 2'];
            % cv = get_cv_ac(trainLabel, [(1:NTrain)' trainData*trainData'], cmd, Ncv);
            
            % With some precal kernel
            scale_str = ['scale_' num2str(sig, '%e')];
            dim_str = ['dim_' num2str(options.dim)];
            kernel_file = fullfile(options.dst_dir, ...
                [...
                options.label '_' ...           % e.g., syn
                'K_inner_product' '_' ...       % IP kernel
                scale_str '_' ...               % PSS time (sigma)
                dim_str '.txt'                  % Hom.-dim.
                ]);
            % Avoid unnecessary recomputation
            if (exist(kernel_file, 'file' ) ~= 2)
                K = pl_SHREC_compute_kernel(X, HKStime, sig, options);
            else
                tmp = load(kernel_file);
                K = pl_normalize_kernel(tmp);
            end
          
            cmd = ['-q -c ', num2str(2^log2c), ' -t 4'];
            cv = get_cv_ac_kernel(label(train), K(train,train), cmd, Ncv);
            if (cv >= bestcv),
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
