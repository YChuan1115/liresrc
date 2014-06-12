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

%- Spatial pyramid -%
posdim = sum(cellfun(@(x) prod(x), fparams.nposbins));

%- Normalization functions -%
norml2    = @(x) bsxfun(@times, x, 1./(sqrt(sum(x.^2,1))+eps));
norml2hel = @(x) sign(x).*norml2(sqrt(abs(x)));

%- Setting -%
vw = load(fullfile(ipath,sprintf('localdesc_gmm%d_%d_%s.mat', nword, struct2hash(lparams), testtype)), 'words','sigma2','priors');
miscdat = struct('vw',vw, 'fw',fw, 'pc',pc);
ldim    = 2*size(vw.words,1)*nword;

%- Feature extraction -%
header = {'train','test'};
for k = 1:numel(header)
	flists = eval([header{k}, 'flist']);
	nflist = numel(flists);
	switch(header{k})
	case 'train'
		fprintf('Computing features in training set\n');
		X = zeros(ldim*posdim,nflist,'single');
	case 'test'
		fprintf('Classifying features in test set\n');
		result = struct('cost', {svmmodel.C}, 'ids',{flists}, 'conf',zeros(nflist,ncls), 'classes',{classes}, 'ID',testID);
	end
	splits = samplepartition(nflist, ceil(nflist/fparams.chunksize));
	for ii = 1:splits.NumTestSets
		nflist_ = splits.TestSize(ii);
		flists_ = flists(splits.test(ii));
		X_      = zeros(ldim*posdim,nflist_,'single');
		parfor i = 1:nflist_
			flist = flists_{i}; 

			%- local descriptor -%
			dat   = lparams.calc_desc(fullfile(imginfo.dirpath, flist),lparams);
			nzidx = sum(abs(dat.F),1) > 0;
			if nnz(nzidx) == 0, continue; end
			F     = double(dat.F(:,nzidx));
			P     = dat.fr(1:2,nzidx);
			S     = dat.fr(4,nzidx);
			p_x   = miscdat.fw.f2wfunc(dat.fr(3,nzidx));
			sum_p_x = sum(p_x);
			p_x   = p_x/sum_p_x;
			if isfield(lparams,'pcadim') && lparams.pcadim
				F = miscdat.pc.V'*F;
			end
	        
	   		%- image feature -%
			M = fisherkernel(F, P, p_x, double(miscdat.vw.words), double(miscdat.vw.sigma2), double(miscdat.vw.priors), fparams.nposbins);
	        
	   		%- normalization -%
			M = norml2(reshape( norml2hel(M), [],1));
			
			X_(:,i) = single(M);
		end

		switch(header{k})
		case 'train'
			X(:,splits.test(ii)) = X_;
		case 'test'
			for icost = 1:numel(result)
				result(icost).conf(splits.test(ii),:) = bsxfun(@minus, X_'*svmmodel(icost).W, svmmodel(icost).rho);
			end
		end
		clear X_;
	end

	switch(header{k})
	case 'train'
		%- Learn classifier: linearSVM -%
		svmmodel = linearsvm_smo(X, trainID, classes, cparams);
		save('-v7.3',fullfile(opath, sprintf('svmmodel_%dword_%d_%d_%d_%s.mat', nword, struct2hash(lparams), struct2hash(fparams), struct2hash(cparams), testtype)),'svmmodel','params');

		if fparams.savefeat
			save('-v7.3',fullfile(opath, sprintf('trainfeat_%dword_%d_%d_%s.mat', nword, struct2hash(lparams), struct2hash(fparams), testtype)),'X','trainID');
		end
		clear K X;
	case 'test'
		save('-v7.3',fullfile(opath, sprintf('result_%dword_%d_%d_%d_%s.mat', nword, struct2hash(lparams), struct2hash(fparams), struct2hash(cparams), testtype)),'result','testID','params');
	end
end
