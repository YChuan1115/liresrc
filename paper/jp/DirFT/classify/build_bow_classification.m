addpath('../feat/');
addpath('../coding/');

nword   = params.nword;
lparams = params.localdesc;
fparams = params.feat;
cparams = params.classifier;

%- Path -%
opath = fullfile(ROOTPATH, 'result/'); mkdir(opath);
ipath = fullfile(ROOTPATH, 'misc/');

imginfo = load(fullfile(ROOTPATH, 'imagefiles.mat'));

%- Load data -%
load(fullfile(ROOTPATH,sprintf('cv_data_%s.mat',testtype)));
pc   = load(fullfile(ipath,sprintf('localdesc_pca_%d_%s.mat',       struct2hash(lparams),testtype)), 'V','E');
fw   = load(fullfile(ipath,sprintf('localdesc_weighting_%d_%s.mat', struct2hash(lparams), testtype)),'f2wfunc','wbins','fw');
ncls = numel(classes);

%- PCA pre-processing if necessary-%
if isfield(lparams,'pcadim') && lparams.pcadim
	pc.V = pc.V(:,1:lparams.pcadim);
end

%- Spatial pyramid weight -%
spweight = cellfun(@(x) repmat(prod(x),1,prod(x)),fparams.nposbins, 'UniformOutput',false);
spweight = 1./sqrt(cat(2, spweight{:}));
posdim   = numel(spweight);

%- Normalization functions -%
norml2     = @(x) bsxfun(@times, x, 1./(sqrt(sum(x.^2,1))+eps));
norml1     = @(x) bsxfun(@times, x, 1./max(sum(x,1),eps));
unfoldfunc = @(x) norml2(reshape(bsxfun(@times,x,spweight),[],size(x,3)));

%- Setting -%
vw = load(fullfile(ipath,sprintf('localdesc_visualwords%d_%d_%s.mat', nword, struct2hash(lparams), testtype)),'words','priors');
miscdat = struct('vw',vw, 'fw',fw, 'pc',pc);
ldim    = nword;

%- Word coding -%
gam   = 1/262144; %for 'uint8' SIFT
gauss = @(x) exp(-gam*x);
vwD   = miscdat.vw.words'*miscdat.vw.words;
vwDd  = 0.5*diag(vwD);
vwK   = single(gauss(bsxfun(@plus, vwDd, vwDd') - vwD)); clear vwD vwDd;
miscdat.codefunc = @(index,d) wordcode(vwK,index,gauss(d));

%- Feature extraction -%
header = {'train','test'};
for k = 1:numel(header)
	flists = eval([header{k}, 'flist']);
	nflist = numel(flists);
	switch(header{k})
	case 'train'
		fprintf('Computing features in training set\n');
		X = zeros(ldim,posdim,nflist,'single');
	case 'test'
		fprintf('Classifying features in test set\n');
		result = struct('cost', {svmmodel.C}, 'ids',{flists}, 'conf',zeros(nflist,ncls), 'classes',{classes}, 'ID',testID);
	end
	splits = samplepartition(nflist, ceil(nflist/fparams.chunksize));
	for ii = 1:splits.NumTestSets
		nflist_ = splits.TestSize(ii);
		flists_ = flists(splits.test(ii));
		X_      = zeros(ldim,posdim,nflist_,'single');
		parfor i = 1:nflist_
			flist = flists_{i};

			%- local descriptor -%
			dat   = lparams.calc_desc(fullfile(imginfo.dirpath, flist),lparams);
			nzidx = sum(abs(dat.F),1) > 0;
			if nnz(nzidx) == 0, continue; end
			F     = dat.F(:,nzidx);
			P     = dat.fr(1:2,nzidx);
			p_x   = miscdat.fw.f2wfunc(dat.fr(3,nzidx));
			sum_p_x = sum(p_x);
			p_x = p_x/sum_p_x;
			if isfield(lparams,'pcadim') && lparams.pcadim
				F  = miscdat.pc.V'*F;
			end
	        
			%- word coding -%
			[inds, dd] = myknn(single(F),single(miscdat.vw.words),fparams.codekNN);
			p_word_x   = miscdat.codefunc(inds, double(dd)); %p(word|x) [n x nword]
	        
	   		%- image feature -%
			M = bow(P, p_x, p_word_x, fparams.nposbins)
	        
	   		%- normalization -%
			M = norml1(M);

			X_(:,:,i) = single(M);
		end

		switch(header{k})
		case 'train'
			X(:,:,splits.test(ii)) = X_;
		case 'test'
			%- Dirichlet Fisher Kernel -%
			X_ = log(X_+direps);
			X_ = norml2(bsxfun(@times, bsxfun(@minus, X_, mu), 1./sig));
			X_ = unfoldfunc(X_);
			for icost = 1:numel(result)
				result(icost).conf(splits.test(ii),:) = bsxfun(@minus, X_'*svmmodel(icost).W, svmmodel(icost).rho);
			end
		end
		clear X_;
	end

	switch(header{k})
	case 'train'
		%- Dirichlet Fisher Kernel -%
		%-- Histogram of logarithmic value --%
		bx = linspace(-40,0,2000);
		H  = zeros(numel(bx),1);
		for i = 1:size(X,3)
			M = X(:,:,i);
			H = H + histc(max(log(M(M>0)),-40),bx);
		end

		%-- 25% percentile --%
		bx = linspace(-40,0,2000);
		% direps = 10^(ceil(log10(0.001*128/size(X,1))));
		direps = exp(bx(find(cumsum(H(2:end)) > 0.25*sum(H(2:end)), 1, 'first')+1)); 
		fprintf('epsilon is %f\n',direps);
		%- Save histogram of logarithmic value -%
		save('-v7.3',fullfile(opath, sprintf('loghist_%dword_%d_%d_%s.mat', nword, struct2hash(lparams), struct2hash(fparams), testtype)),'bx','H','direps','params');

		%- Dirichlet Fisher Kernel -%
		X  = log(X+direps);
		mu = mean(X,3);
		sig= max(std(X,1,3),1e-2);
		X  = norml2(bsxfun(@times, bsxfun(@minus, X, mu), 1./sig));
		X  = unfoldfunc(X);

		%- Learn classifier: linearSVM -%
		svmmodel = linearsvm_smo(X, trainID, classes, cparams);
		save('-v7.3',fullfile(opath, sprintf('svmmodel_%dword_%d_%d_%d_%s.mat', nword, struct2hash(lparams), struct2hash(fparams), struct2hash(cparams), testtype)),'svmmodel','params');

		if fparams.savefeat
			save('-v7.3',fullfile(opath, sprintf('trainfeat_%dword_%d_%d_%d_%s.mat', nword, struct2hash(lparams), struct2hash(fparams), testtype)),'X','trainID','params');
		end
		clear X;
	case 'test'
		save('-v7.3',fullfile(opath, sprintf('result_%dword_%d_%d_%d_%s.mat', nword, struct2hash(lparams), struct2hash(fparams), struct2hash(cparams), testtype)),'result','testID','params');
	end
end
