function svmmodel = linearsvm_smo(X, trainID, classes, params)

%- Init. -%
n    = size(X,2);
ncls = numel(classes);
svmmodel = struct('C',num2cell(params.cost), 'rho',[], 'W',[], 'classes',{classes});
alpha0   = zeros(n, ncls);
K = double(X'*X);

for i = 1:numel(svmmodel)
	cost = svmmodel(i).C;
	svmparam = sprintf('-c %f -q 1',cost);
	fprintf('linearSVM with C = %1.1f\n',cost);
	coef = zeros(n, ncls);
	rhos = zeros(1, ncls);
	parfor c = 1:ncls
		if numel(trainID) == n
			% numeric class ID
			y = 2*(trainID == c) - 1;
		else
			% ncls-dimensional binary class ID
			y = trainID(:,c);
		end
		nzidx = (y~=0);
		initalpha = alpha0(:,c);
		[alphas, stats] = smo(y(nzidx), K(nzidx,nzidx), -ones(nnz(nzidx),1),[],initalpha(nzidx),svmparam);

		initalpha(nzidx) = alphas;
		alpha0(:,c)      = initalpha;

		coef(:,c) = double(nzidx).*initalpha.*y;
		rhos(c)   = stats.rho;
	end
	svmmodel(i).W    = X*coef;
	svmmodel(i).rho  = rhos;
end
