function E = posgmm(X, m, sig2, w)
%
% POSGMM - Posterior on GMM
%
%  prob = posgmm(X, mu, sig2, w)
%
% Input:
%   X  - Sample vectors [d x n]
%   m    - Mean vectors [d x k]
%   sig2 - (Diagonal) variances [d x k]
%   w    - Prior weights [1 x k]
%
% Output:
%   prob - Posterior probabilities [k x n]
%

norml1 = @(x) bsxfun(@times, x, 1./sum(x,1));

invsig2 = 1./sig2;
msig = bsxfun(@times, m, invsig2);
E = bsxfun(@plus, bsxfun(@minus, bsxfun(@minus,msig'*X,0.5*sum(m.*msig,1)'), (0.5*invsig2')*(X.^2)), (log(w)+0.5*sum(log(invsig2),1))');
maxE = max(E,[],1);
E = exp(bsxfun(@minus,E,maxE)); 
E = norml1(E);
E(E<1e-4) = 0;
E = norml1(sparse(E));
