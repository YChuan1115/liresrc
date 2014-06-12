function [grad, prob] = pdfgrad(X, p_x, gfunc)
%
% PDFGRAD - p.d.f gradient vectors
%
%  [grad prob] = pdfgrad(X, w, gfunc)
%
% Input:
%  X - Sample vectors [dim x n]
%  w - Weights on the samples [1 x n]
%  gfunc - Profile function, such as @(d) exp(-10*d) [func_handler]
%          Note that d = 0.5*||x_i - x_j||^2.
%
% Output:
%  grad - Gradient vectors  [dim x n]
%  prob - Probability density [1 x n]
%

p_x = reshape(p_x,1,[]);

D  = X'*X;
sd = 0.5*diag(D);
W  = gfunc(bsxfun(@plus, sd, sd') - D);
prob = p_x*W;

X_ = bsxfun(@times, p_x, X);

grad = bsxfun(@times, 1./prob, X_*W) - X;
