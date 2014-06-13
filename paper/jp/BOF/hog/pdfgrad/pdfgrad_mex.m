function [grad, prob] = pdfgrad_mex(X, p_x, gfunc)
%
% PDFGRAD_MEX - p.d.f gradient vectors using mex functions
%
%  [grad prob] = pdfgrad_mex(X, w, gfunc)
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

p_x = reshape(single(p_x),1,[]);

gammas = log(gfunc(-1));

W  = Pxx_mex(X, gammas);
prob  = ssymv_mex(W, p_x);

X_ = bsxfun(@times, p_x, X);

grad = bsxfun(@times, 1./prob, ssymm_mex(W, X_)) - X;
