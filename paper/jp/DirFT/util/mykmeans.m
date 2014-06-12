function [m, w, label, cost] = mykmeans(X, k, params)
% 
% MYKMEANS - K-means
%  
%  [m w label] = mykmeans(X, k, params)
%
% Input:
%   X - Sample vectors [d x n]
%   k - Number of clusters [scalar]
%   params - Parameters [struct]
%    .maxiter - Maximum number of iterations [{500}]
%    .costtol - Threshold for cost difference [{1e-4}]
%    .verbose - Verbosity [{true}]
%    .weight  - Sample weight [n x 1| NaN]
%    .init    - Initialization method ['kmeans++'|'random'] (default 'kmeans++')
%
% Output:
%  m - Mean vectors [d x k]
%  w - Prior weights [1 x k]
%  label - Membership ID [1 x n]
%

if ~exist('params','var') || isempty(params), params = struct; end
params = parseparam(params, 'maxiter',500,'verbose',true,'costtol',1e-4,'weight',NaN, 'init','kmeans++');

[dim,n] = size(X);

dX2      = 0.5*sum(X.^2,1);
costbias = sum(dX2);

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
	m = X(:,randperm(size(X,2), k));
otherwise
	error('wrong parameter of init')
end

if any(isnan(params.weight))
	W = ones(1, n);
else
	W = reshape(params.weight, 1, n);
end

if params.verbose
	figure(1);p = plot(0,NaN,'bx-');set(gca,'yscale','log');xlabel('iter.');ylabel('cost');
end
lastcost = NaN; initcost = NaN;
for iter = 1:params.maxiter
    [d,label] = max(bsxfun(@minus,m'*X,0.5*dot(m,m,1)'),[],1); % assign samples to the nearest centers

	cost = (costbias - sum(d))/n; 
	diffcost = (lastcost - cost)/(initcost - cost);
	
	if params.verbose
		set(p,'YData',[get(p,'Ydata'),cost],'XData',[get(p,'Xdata'),iter]);title(cost);drawnow;
	end

	%- Update -%
	if isnan(initcost), initcost = cost; end
	lastcost = cost;
	E = sparse(1:n,label,W, n,k,n);  % transform label into indicator matrix
	w = full(sum(E,1));
	m_ = double(X)*(E*spdiags(1./w',0,k,k));    % compute m of each cluster
	nzidx = w > 0;
	m(:,nzidx) = m_(:,nzidx);
	if any(~nzidx)
		d = max(dX2 - d,0);
		for i = find(~nzidx)
			ind = find(rand(1)*sum(d)<cumsum(d),1,'first');
			m(:,i) = X(:,ind);
			d(ind) = 0;
		end
	end
	m = single(m);

	%- Termination check -%
	if (diffcost < params.costtol)
		if(params.verbose), fprintf('kmeans converged.\n'); end
   		break; 
	end
end
