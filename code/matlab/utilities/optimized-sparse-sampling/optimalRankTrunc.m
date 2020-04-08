function [ U, r_opt, energy ] = optimalRankTrunc( X )

[U,S,~] = svd(X,'econ');

% update to use Gavish-Donoho truncation parameter
m = min(size(X)); n = max(size(X));
sig = diag(S)/sum(diag(S));

thres = optimal_SVHT_coef(m/n,0)*median(sig);
r_opt = length(sig(sig>thres));
disp(['Gavish-Donoho optimal rank truncation=' num2str(r_opt)]);

energy = cumsum(diag(S))/sum(diag(S));
disp(['energy contained in first r_opt modes=' num2str(energy(r_opt)*100) '%']);

end