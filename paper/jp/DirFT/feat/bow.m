function M = bow(P, p_x, p_word_x, pbins)
%
% BOW - Bag-of-words feature
%
%  M = bow(pos, p_x, p_word_x, posbin)
%
% Input:
%  pos   - 2D-position vectors [2 x n]
%  p_x   - Weights on those features [1 x n]
%  p_word_x - Word weight on samples [nword x n]
%  posbin- Number of spatial bins in 2D positions [nsp x 1 (cell, 1 x 2)]
%          as in spatial pyramid
% 
% Output:
%  M - Word histogram features [nword x nposall]
%

nword = size(p_word_x,1);
nsp   = numel(pbins);

p_x = p_x/sum(p_x);

p_xword = bsxfun(@times, p_x, p_word_x); %p(x,word)

p_xword_pos = cell(nsp,1);
for i = 1:nsp
	p_xword_pos{i} = sppart(P, pbins{i}, p_xword, p_x, 'soft');
end
p_xword_pos = cat(1,p_xword_pos{:})';
p_word_pos  = full(sum(p_xword_pos,1));
nallpbin    = sum(cellfun(@(x) prod(x), pbins));

M = reshape(p_word_pos, nword, nallpbin);
