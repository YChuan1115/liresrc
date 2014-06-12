addpath('../feat/');
addpath('../coding/');
addpath('../pdfgrad/');

%- Path -%
opath    = fullfile(ROOTPATH, 'result/'); mkdir(opath);
phowpath = fullfile(ROOTPATH, 'phow_desc/');
vwpath   = fullfile(ROOTPATH, 'visualwords/');
dppath   = fullfile(ROOTPATH, 'phow_pca/');
gdpath   = fullfile(ROOTPATH, sprintf('grad_dir%s/',suffix));

%- Func. -%
norml2    = @(x) bsxfun(@times, x, 1./(sqrt(sum(x.^2,1))+eps));
norml2hys = @(x) norml2(min(norml2(x),1/sqrt(size(x,1))));
myfunc2str= @(x) regexprep(func2str(x),{'\@\([\w\,]+\)','\/','*','(',')'},{'','_','','',''});
profile = @(x) exp((-10/262144)*x); %512^2=262144

%- Init -%
footer = sprintf('%d-',[16,24,32]);
profilename = myfunc2str(profile);

%- Load data -%
load(fullfile(ROOTPATH,sprintf('cv_data_%s.mat',testtype)));
vw = load(fullfile(vwpath,sprintf('visualwords%d_size%s_%s.mat',nword,footer,testtype)));
gdirname = 'pca';
gdir = load(fullfile(gdpath,sprintf('grad_%s_%s_size%s_%s.mat',gdirname,profilename,footer,testtype)));
descpca  = load(fullfile(dppath,sprintf('PHOW_pca_size%s_%s.mat',footer,testtype)));

%- Parameters -%
featparams = struct('tau',0.9, 'kNNword',10, 'nposbins',{{[1;3],[2;2],[1;1]}});
paramname  = sprintf('grad%s_%s_tau%1.1f-k%d_word%d_size%s_%s', gdirname, profilename, featparams.tau, featparams.kNNword, nword, footer, testtype);

%- Spatial pyramid weight -%
spweight = cellfun(@(x) repmat(prod(x),1,prod(x)),featparams.nposbins, 'UniformOutput',false);
spweight = 1./sqrt(cat(2, spweight{:}));

%- Feature -%
header = {'train','test'};
for k = 1:numel(header)
	flists = eval([header{k}, 'flist']);
	nflist = numel(flists);
	X = cell(nflist,1);
	parfor i = 1:nflist
		flist = flists{i}; 

		%- local feature -%
		dat = load(fullfile(phowpath, sprintf('%s_PHOW_size%s.mat',flist,footer)));
		nzidx = sum(dat.F,1) > 0;
		F   = dat.F(:,nzidx);
		P   = dat.fr(1:2,nzidx);
       	S   = dat.fr(4,nzidx)';
		p_x = vw.f2wfunc(dat.fr(3,nzidx));
		p_x = p_x/sum(p_x);
        
		%- word coding -%
		[inds, dd] = myknn(single(F),single(vw.words),featparams.kNNword);
		p_word_x = drc(nword, inds, double(dd)); %p(word|x) [n x nword]
        
   		%- Image descriptor -%
		G = []; M = [];
		%- p.d.f gradient -%
		[G, ~] = pdfgrad(single(F), single(p_x), profile);
		M = hopdfg(double(G), P, p_x, gdir.dirs, gdir.weights, p_word_x, featparams.tau, featparams.nposbins);
        
   		%- Normalization -%
		M = bsxfun(@times, norml2hys(M), spweight);
		X{i} = reshape(single(M/sqrt(sum(M(:).^2))),[],1);
	end
	eval(sprintf('%sX = cat(2,X{:}); clear X;',header{k}));
end

%- Kernel Gram matrix -%
Ky = double(testX'*trainX);  clear testX;
K  = double(trainX'*trainX); clear trainX;
K  = bsxfun(@times, bsxfun(@times, 1./sqrt(diag(K)),K), 1./sqrt(diag(K)'));

%- SVM Classification -%
addpath(PATH_TO_SMO);
result = struct('cost', num2cell(costs), 'ids',[], 'conf',[], 'classes',[]);
for icost = 1:numel(costs)
	cost = costs(icost);
	for c = 1:size(trainID,2)
		y = trainID(:,c);
		nzidx = (y~=0);
		[alphas, stats] = smo(y(nzidx), K(nzidx,nzidx), -ones(nnz(nzidx),1),[],zeros(nnz(nzidx),1),sprintf('-c %f -q 1',cost));

		testval = Ky(:,nzidx)*(alphas.*y(nzidx)) - stats.rho;

		result(icost).ids  = testflist;
		result(icost).conf(:,c) = testval;
	end
	result(icost).classes = classes;
end
rmpath(PATH_TO_SMO);

save('-v7.3',fullfile(opath, sprintf('result_%s.mat', paramname)),'result');
