function [p_xword_pos, p_word_pos] = sppart(P, pbin, p_xword, p_x, flag)
%
% SPPART - Spatial partitioning
%
%  [p_xword_pos, p_word_pos] = sppart(P, posbin, p_xword, p_x, hardflag)
%
% Input:
%  P - Position vectors [2 x n]
%  posbin - Number of spatial bins [2 x 1]
%  p_xword - p(x,word) [nword x n]
%  p_x - p(x) [1 x n]
%  flag - Hard partition / soft partition ['hard'|'soft']
%
% Output:
%  p_xword_pos - p(x,word|pos) [nword*nbin x n]
%  p_word_pos  - p(word|pos)   [nword*nbin x 1]
%

n = size(P,2);
npbin = prod(pbin);

if npbin == 1 %whole region
	p_word = sum(p_xword,2); %p(word)
	p_xword_pos = p_xword;
	p_word_pos  = p_word;
else
	minP = min(P, [], 2);
	maxP = max(P, [], 2);
	switch(flag)
	case 'hard'
		Pn = bsxfun(@times, bsxfun(@minus, P, minP), pbin./(maxP-minP));
		spind   = bsxfun(@min, floor(Pn), pbin-1);
		p_pos_x = sparse([1,pbin(1)]*spind+1, 1:n, 1, npbin, n);%p(pos|x)
	case 'soft'
		Pn = bsxfun(@times, bsxfun(@minus, P, minP), pbin./(maxP-minP)) - 0.5;
		lspind = floor(Pn);
		rspind = lspind + 1;
		 spind = [lspind(1,:)+lspind(2,:)*pbin(1); lspind(1,:)+rspind(2,:)*pbin(1);...
				  rspind(1,:)+lspind(2,:)*pbin(1); rspind(1,:)+rspind(2,:)*pbin(1)]; 
		rspwei = Pn - lspind; 
		lspwei = 1 - rspwei;
		lspwei(lspind<0) = 0;
		rspwei(bsxfun(@gt, rspind, pbin-1)) = 0;
		 spwei = [lspwei(1,:).*lspwei(2,:); lspwei(1,:).*rspwei(2,:); rspwei(1,:).*lspwei(2,:); rspwei(1,:).*rspwei(2,:)];
		nzidx = spwei>0;
		pinds = repmat(1:n,4,1);
		p_pos_x = sparse(spind(nzidx)+1, pinds(nzidx), spwei(nzidx), npbin, n); %p(pos|x)
	otherwise
		error('wrong flag.');
	end
	p_pos = p_pos_x*p_x'; %p(pos)

	p_xword_pos = cell(npbin,1);
	for i = 1:npbin
		p_xword_pos{i} = bsxfun(@times, p_pos_x(i,:)/(p_pos(i)+eps), p_xword); %p(x,word|pos) = p(x,word)*p(pos|x)/p(pos)
	end
	p_xword_pos = cat(1, p_xword_pos{:});
	p_word_pos  = full(sum(p_xword_pos,2)); %p(word|pos)
end
