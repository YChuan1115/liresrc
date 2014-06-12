%- Parameters -%
nword   = params.nword;
lparams = params.localdesc;

%- Path -%
opath = fullfile(ROOTPATH,'misc/'); mkdir(opath);

imginfo = load(fullfile(ROOTPATH, 'imagefiles.mat'));

%- Load data -%
load(fullfile(ROOTPATH,sprintf('cv_data_%s.mat',testtype)));
ntrainsample = numel(vwtrainflist);
num_per_file = round(1e6/ntrainsample);

%- Check descriptor dim. -%
dat = lparams.calc_desc(fullfile(imginfo.dirpath,imginfo.flists{1}),lparams);
dim = size(dat.F(:,1),1); 
clear dat;

%- For PCA -%
R   = zeros(dim);
mu  = zeros(dim,1);
num = 0;

%- For building codebook -%
X = cell(ntrainsample,1);

%- For descriptor norm hist. -%
wbins  = linspace(0,0.1,1000)';
C = zeros(ntrainsample, numel(wbins));

fprintf('Extracting local descriptors\n');
parfor i = 1:ntrainsample
	flist = vwtrainflist{i};
	dat   = lparams.calc_desc(fullfile(imginfo.dirpath, flist),lparams);
	nzidx = sum(abs(dat.F),1) > 0;
	F_    = double(dat.F(:,nzidx));
	R     = R + F_*F_';
	mu    = mu + sum(F_,2);
	num   = num + size(F_,2);

	%- Random pickup -%
	rind  = randperm(size(F_,2),min(num_per_file,size(F_,2)));
	X{i}  = single(F_(:,rind));
	
	%- Construct hist. of descriptor norms -%
	C(i,:)= histc(dat.fr(3,:), wbins);
end

%- Descriptor norm hist. used for weighting descriptors -%
fw = sum(C,1); fw(1) = 0;
fw = cumsum(fw)/sum(fw);
f2wfunc = @(x) fw(sum(bsxfun(@ge,x,wbins),1));
save(fullfile(opath,sprintf('localdesc_weighting_%d_%s.mat', struct2hash(lparams), testtype)), 'f2wfunc','wbins','fw','lparams');

%- PCA -%
mu = mu/num;
R  = R/num;
[V,E] = svd(R-mu*mu',0);
E = diag(E);
save(fullfile(opath,sprintf('localdesc_pca_%d_%s.mat',struct2hash(lparams),testtype)), 'V','E','mu','lparams');

%- Codebook -%
X = cat(2,X{:});
%- PCA pre-processing if necessary -%
if isfield(lparams,'pcadim') && lparams.pcadim
	X = single(V(:,1:lparams.pcadim)'*X);
end
fprintf('EM: %4d-clusters\n', nword);
[words, sigma2, priors] = myem(X, nword);
save(fullfile(opath,sprintf('localdesc_gmm%d_%d_%s.mat', nword, struct2hash(lparams), testtype)), 'words','sigma2','priors','lparams');
