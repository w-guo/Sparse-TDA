function [ r_opt, energy, loc ] = optimalMeasurements( X, p )
%optimalMeasurements
% Finds r optimal discrete measurement locations in m-dimensional state
% space that best approximate r-dimensional feature space  
%
% See Z. Drmac and S. Gugercin, "A New Selection Operator for the Discrete 
% Empirical Interpolation Method--improved a priori error bound 
% and extensions.", http://arxiv.org/abs/1305.5870
%
% IN: 
%    X: Input mxn data matrix 
%    p: Number of desired measurements
% 
% OUT: 
%    r_opt: Gavish-Donoho optimal rank truncation
%    energy: energy contained in first r_opt modes
%    loc: optimal measurement indices of m-dim states
%
% Usage:
%
%   Given an m-by-n matrix X known to be low rank of rank r, find r optimal
%   measurement locations in m-dim state space
%
%   [~,~,loc] = optimalMeasurements(X, 30);
%   state = X(:,1);
%   measurements = state(loc);
% 
% -----------------------------------------------------------------------------
% Author: Krithika Manohar
% -----------------------------------------------------------------------------

[U,S,~] = svd(X,'econ');


% update to use Gavish-Donoho truncation parameter
m = min(size(X)); n = max(size(X));
sig = diag(S)/sum(diag(S));

thres = optimal_SVHT_coef(m/n,0)*median(sig);
r_opt = length(sig(sig>thres));
disp(['Gavish-Donoho optimal rank truncation=' num2str(r_opt)]);

energy = cumsum(diag(S))/sum(diag(S));
disp(['energy contained in first r_opt modes=' num2str(energy(r_opt)*100) '%']);

Ur = U(:,1:r_opt);

assert(p>=r_opt);

if (p==r_opt)
    [~,~,pivot] = qr(Ur.',0);
else 
    [~,~,pivot] = qr(Ur*Ur.',0);
end

loc = pivot(1:p);

end

