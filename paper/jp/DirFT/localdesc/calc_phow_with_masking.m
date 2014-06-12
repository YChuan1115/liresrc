function dat = calc_phow_with_masking(imgfname, params)

%- Parameters -%
if ~exist('params', 'var') || isempty(params), params = struct; end
params = parseparam(params, 'step',4, 'patchsizes',[16,24,32], 'floatdescriptors',0, 'normalizationtype',2, 'dirichleteps',0.001);

img = im2single(imread(imgfname));

mskfname = [imgfname,'.mask.bmp'];
msk = imread(mskfname) > 0;

%- descriptors -%
[fr, F] = vl_phow(img, 'Sizes',params.patchsizes/4, 'Step',params.step, ...
			'FloatDescriptors',params.floatdescriptors,'NormalizationType',params.normalizationtype,'DirichletEps',params.dirichleteps);

%- Masking -%
nzidx = msk(sub2ind([size(img,1),size(img,2)],fr(2,:),fr(1,:)));
dat   = struct('F',F(:,nzidx), 'fr',fr(:,nzidx));
