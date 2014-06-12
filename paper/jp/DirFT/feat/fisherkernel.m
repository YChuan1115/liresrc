function M = fisherkernel(X, P, p_x, words, sig2, w, pbins)
%
% FISHERKERNEL - Fisher kernel feature
%
%  M = FisherKernel(feats, pos, weis, words, sig2, w, nposbin, flag)
%
% Input:
%  feats - Feature vectors  [dim x n]
%  pos   - 2D-position vectors [2 x n]
%  p_x   - Weights on those features [1 x n]
%  words - Bases feature vectors (words) in the distribution [dim x nword]
%  sig2  - (Diagonal) variances [dim x nword]
%  w     - Prior weights [1 x nword]
%  posbin- Number of spatial bins in 2D positions [nsp x 1 (cell, 2 x 1)]
%          as in spatial pyramid
%
% Output:
%  M - Fisher kernel features [2*dim*nword x nposall]
%

nword = size(words,2);
nsp   = numel(pbins);

p_word_x = double(posgmm(X, words, sig2, w));

p_x = p_x/sum(p_x);

p_xword = bsxfun(@times, p_x, p_word_x); %p(x,word)

p_xword_pos = cell(nsp,1);
for i = 1:nsp
	p_xword_pos{i} = sppart(P, pbins{i}, p_xword, p_x, 'soft');
end
p_xword_pos = cat(1,p_xword_pos{:})';
p_word_pos  = full(sum(p_xword_pos,1));
nallpbin    = sum(cellfun(@(x) prod(x), pbins));

xp = X*p_xword_pos;
Mmu  = (xp - bsxfun(@times, repmat(words,1,nallpbin), p_word_pos))./repmat(sqrt(bsxfun(@times,sig2,w))+eps,1,nallpbin);
Msig = ((X.^2)*p_xword_pos - 2*xp.*repmat(words,1,nallpbin) + bsxfun(@times, repmat(words.^2-sig2,1,nallpbin), p_word_pos))./repmat(bsxfun(@times,sig2,sqrt(2*w))+eps,1,nallpbin);

M_ = [Mmu; Msig];
M  = reshape(M_, nword*size(M_,1), nallpbin);
