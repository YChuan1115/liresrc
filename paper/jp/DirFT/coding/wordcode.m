function P = wordcode(K, inds, Ky)
%
% Soft word coding
%

m = size(K,1);
[knum, n] = size(Ky);

p = wordcode_mex(double(K), -double(Ky), double(inds),struct('e',1e-5,'c',1));
P = sparse(inds, repmat(1:n,knum,1), p, m, n);
