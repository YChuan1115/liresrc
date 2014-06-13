%- Path -%
opath = fullfile(ROOTPATH,'visualwords/'); mkdir(opath);
phowpath = fullfile(ROOTPATH,'phow_desc/');

%- Load data -%
load(fullfile(ROOTPATH,sprintf('cv_data_%s.mat',testtype)));
ntrainsample = numel(vwtrainflist);

%- Parameters -%
footer = sprintf('%d-',[16,24,32]);
wbins  = linspace(0,0.1,1000)';
num_per_file = round(1e6/ntrainsample);

X = cell(ntrainsample,1);
C = zeros(ntrainsample, numel(wbins));

for i = 1:ntrainsample
	flist = vwtrainflist{i};
	dat   = load(fullfile(phowpath, sprintf('%s_PHOW_size%s.mat',flist,footer)));
	nzind= find(dat.fr(3,:) > 0.01 & sum(dat.F,1) > 0);
	rind  = randperm(numel(nzind),min(num_per_file,numel(nzind)));
	X{i}  = dat.F(:,nzind(rind));
	C(i,:) = histc(dat.fr(3,:), wbins);
end

X  = single(cat(2,X{:}));
fw = sum(C,1); fw(1) = 0;
fw = cumsum(fw)/sum(fw);

for nbin = 256
	fprintf('\nK-means: %4d-clusters\n', nbin);
	randind = randperm(size(X,2), nbin);
	[words, priors] = mykmeans(X, X(:,randind));
	f2wfunc = @(x) fw(sum(bsxfun(@ge,x,wbins),1));

	save(fullfile(opath,sprintf('visualwords%d_size%s_%s.mat',nbin, footer, testtype)), 'words','priors','f2wfunc','wbins','fw');
end
