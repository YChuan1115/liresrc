function M = hopdfg(dX, P, p_x, dirs, wdirs, p_word_x, tau, pbins)
%
% HOPDFG - Histogram of Oriented p.d.f Gradient
%
%  M = hopdfg(grads, pos, p_x, dirs, wdirs, p_word_x, tau, posbin)
%
% Input:
%  grads - Gradient vectors [dim x n]
%  pos   - 2D-position vectors [2 x n]
%  p_x   - Weights on those features [1 x n]
%  dirs  - Orthonormal projection for the gradients  [dim x d]
%  wdirs - Weights for the projections [1 x d]
%  p_word_x - Word weight on samples [nword x n]
%  tau   - Threshold for orientation coding [scalar(<=1)]
%  posbin- Number of spatial bins in 2D positions [nsp x 1 (cell, 1 x 2)]
%          as in spatial pyramid
%
% Output:
%  M - HoG-Bof features [2*d*nword x nposall]
%

nword = size(p_word_x,1);
nsp   = numel(pbins);

p_x = p_x/sum(p_x);

normdX = sqrt(sum(dX.^2,1));
dXn = bsxfun(@times, dX, 1./(normdX+eps));

W = dircode(dXn, dirs, tau);

p_xword = bsxfun(@times, p_x, p_word_x); %p(x,word)

p_xword_pos = cell(nsp,1);
for i = 1:nsp
	p_xword_pos{i} = sppart(P, pbins{i}, p_xword, p_x, 'soft');
end
p_xword_pos = cat(1,p_xword_pos{:})';
p_word_pos  = full(sum(p_xword_pos,1));
nallpbin    = sum(cellfun(@(x) prod(x), pbins));

M_ = bsxfun(@times, W, normdX)*p_xword_pos;
M_ = M_.*bsxfun(@times, repmat(wdirs',2,1), 1./(p_word_pos+eps));
M  = reshape(M_, nword*size(M_,1), nallpbin);
