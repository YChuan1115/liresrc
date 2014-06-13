%- Path -%
opath    = fullfile(ROOTPATH,'grad_dir'); mkdir(opath);
phowpath = fullfile(ROOTPATH,'phow_desc/');
vwpath   = fullfile(ROOTPATH,'visualwords/');
dppath   = fullfile(ROOTPATH,'phow_pca/');

%- Func. -%
myfunc2str = @(x) regexprep(func2str(x),{'\@\([\w\,]+\)','\/','*','(',')'},{'','_','','',''});
norml2  = @(x) bsxfun(@times, x, 1./(sqrt(sum(x.^2,1))+eps));
profile = @(x) exp((-10/262144)*x); %512^2=262144

%- Init -%
footer = sprintf('%d-',[16,24,32]);

%- Load data -%
vw = load(fullfile(vwpath,sprintf('visualwords%d_size%s_%s.mat',256,footer,testtype)));
descpca = load(fullfile(dppath,sprintf('PHOW_pca_size%s_%s.mat',footer,testtype)));

%- subset -%
cvdat = load(fullfile(ROOTPATH,sprintf('cv_data_%s.mat',testtype)));
list  = struct('name',cellfun(@(x) sprintf('%s_PHOW_size%s.mat',x,footer), cvdat.vwtrainflist, 'UniformOutput',false));
fprintf('Total number of files is %d\n', numel(list));

X   = zeros(128);
num = 0;
for i = 1:numel(list)
	fname = list(i).name;
	fprintf('%s\r',fname);
	%- Load data -%
	dat   = load(fullfile(phowpath, fname));
	nzidx = sum(dat.F,1) > 0;
	F_    = single(dat.F(:,nzidx));
	S_    = dat.fr(4,nzidx);
	wei_  = single(vw.f2wfunc(dat.fr(3,nzidx)));

	%- Compute k.d.e in respective cells -%
	[G_,~] = pdfgrad_mex(F_, wei_, profile);
%	[G_,~] = pdfgrad(F_, wei_, profile);

	g   = norml2(G_);
	X   = X + double(g*g');
	num = num + size(g,2);
end

[dirs,E] = svd(X/num,'econ');
weights  = 1./diag(E)';

save(fullfile(opath,sprintf('grad_pca_%s_size%s_%s.mat',myfunc2str(profile),footer,testtype)), 'dirs','weights');
