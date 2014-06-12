function X = dircode(x, V, tau)
%
% DIRCODE - Gradient orientation code based on principal vectors
%  X = dircode(x, V, t)
%
% Input:
%  x - Input sample vectors normalized in L2-unit norm [dim x n]
%  V - Orthonormal projection vectors [dim x m]
%  t - Threshold for contributing rate (0~1) [scalar]
%
% Output:
%  X - Quantized representation [2*m x n]
%

[dim, n] = size(x);
y  = V'*x;
y2 = y.^2;
sy2  = sort(y2, 1, 'descend');
inds = min(sum(bsxfun(@lt, cumsum(sy2,1), tau), 1)+1, dim);
zidx = bsxfun(@lt, y2, sy2(sub2ind([dim,n],inds,1:n)));
y(zidx) = 0;
X = max([y;-y],0).^2;
