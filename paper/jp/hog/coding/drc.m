function P = drc(m, inds, d)
%
% DRC - Distance ratio based coding
%
%  P = drc(m, inds, D)
%
% Input:
%  m - Size of dictionary [scalar]
%  inds - k-NN sample index [k x n]
%  D    - Distances         [k x n]
%
% Output:
%  P - Word codes [m x n]
%
% [1] T. Kobayashi and N. Otsu, "Bag of Hierarchical Co-occurrence Features for Image Classification", ICPR2010.
%

norml1 = @(x) bsxfun(@times, x, 1./sum(x,1));

[knum, n] = size(inds);

p = bsxfun(@times, d(1,:), 1./d); p(1,:) = 1;
p = norml1(p);

P = sparse(inds, repmat(1:n,knum,1), p, m, n);
