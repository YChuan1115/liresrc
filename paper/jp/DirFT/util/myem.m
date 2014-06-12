function [m, sig2, w] = myem(X, k, params)
% 
% MYEM - EM clustering for GMM
%
%  [m sig2 w] = myem(X, mu, params)
%
% Input:
%   X  - Sample vectors [d x n]
%   mu - Initial mean vectors   [d x k]
%   params - Parameters [struct]
%    .alpha   - Dirichlet priors for w [{0}]
%    .maxiter - Maximum number of iterations [{500}]
%    .costtol - Threshold for cost difference [{1e-3}]
%    .varfactor- Factor of the total variance for minimum variances [{1e-2}]
%    .verbose - Verbosity [{true}]
%    .init    - Initialization method ['kmeans++'|'random'] (default 'kmeans++')
%
% Output:
%   m    - Mean vectors [d x k]
%   sig2 - (Diagonal) variances [d x k]
%   w    - Prior weights [1 x k]
%

if ~exist('params','var') || isempty(params), params = struct; end
params = parseparam(params, 'maxiter',500,'verbose',true,'costtol',1e-3,'varfactor',1e-2,'alpha',0, 'init','kmeans++');

[dim,n] = size(X);

X2 = X.^2;

dX2 = 0.5*sum(X2,1);
m = zeros(dim,k,class(X));
switch(params.init)
case 'kmeans++'
	for i = 1:k
		if i == 1
			ind = randi(n,1);
			D   = inf(1,n);
		else
			D = min( cat(1, D, 0.5*sum(m(:,i-1).^2)+dX2-m(:,i-1)'*X), [],1); 
			% m_  = m(:,1:i-1);
		    % D   = max(min(bsxfun(@plus,0.5*sum(m_.^2,1)',dX2)-m_'*X,[],1),0);
			ind = find(rand(1)*sum(D)<=cumsum(D),1,'first');
		end
		m(:,i) = X(:,ind);
	end	
case 'random'
	m = X(:,randperm(n, k));
otherwise
	error('wrong parameter of init')
end

%- Init -%
[~,label] = max(bsxfun(@minus,m'*X,0.5*sum(m.^2,1)'),[],1); % assign samples to the nearest centers
E = sparse(1:n,label,1, n,k,n);  % transform label into indicator matrix
w = full(sum(E,1));
E = E*spdiags(1./w',0,k,k);
m = single(double(X)*E);
sig2 = single(double(X2)*E) - m.^2;
w = w + params.alpha*n;
w = w/sum(w);

minsig2 = single(repmat((mean(X2,2) - mean(X,2).^2)*params.varfactor, 1, k));
sig2 = max(sig2,minsig2);

if params.verbose
	figure(1);p = plot(0,NaN,'bx-');set(gca,'yscale','linear');xlabel('iter.');ylabel('cost');
end
lastcost = NaN; initcost = NaN;
for iter = 1:params.maxiter
	%- Compute memberships -%
    invsig2 = 1./sig2;
	msig = bsxfun(@times, m, invsig2);
    E = bsxfun(@plus, ...
			bsxfun(@minus, bsxfun(@minus,msig'*X,0.5*sum(m.*msig,1)'), (0.5*invsig2')*X2), single(log(w)+0.5*sum(log(invsig2),1))');
	maxE = max(E,[],1);
	E = exp(bsxfun(@minus,E,maxE)); 
	cost = -mean(log(sum(E,1))+maxE);
	if params.verbose
		set(p,'YData',[get(p,'Ydata'),cost],'XData',[get(p,'Xdata'),iter]);title(cost); drawnow;
	end
	E = bsxfun(@times, E, 1./sum(E,1));

	diffcost = (lastcost - cost)/(initcost - cost);

	%- Update -%
	if isnan(initcost), initcost = cost; end
	lastcost = cost;
	w  = sum(E,2)';
    m_ = single(bsxfun(@times,X*E',1./w));    % compute m of each cluster
	m(:,w>0) = m_(:,w>0);
	
    sig2_= single(bsxfun(@times,X2*E',1./w)) - m.^2;    % compute m of each cluster
	sig2(:,w>0) = sig2_(:,w>0);
	sig2 = max(sig2, minsig2); 

	w = w + params.alpha*n;
	w = w/sum(w);
	
	%- Termination check -%
	if (diffcost < params.costtol)
		if(params.verbose), fprintf('\nem converged.\n'); end
   		break; 
	end
end
