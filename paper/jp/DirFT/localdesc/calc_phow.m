function dat = calc_phow(fname, params)
%
% Compute SIFT local descriptors
%

%- Parameters -%
if ~exist('params', 'var') || isempty(params), params = struct; end
params = parseparam(params, 'step',4, 'patchsizes',[16,24,32], 'floatdescriptors',0, 'normalizationtype',2, 'dirichleteps',0.001);

img = im2single(imread(fname));

%- standarize image -%
if size(img,1) > 480
	img = imresize(img, [480 NaN]); 
end

%- descriptors -%
[fr, F] = vl_phow(img, 'Sizes',params.patchsizes/4, 'Step',params.step, ...
			'FloatDescriptors',params.floatdescriptors,'NormalizationType',params.normalizationtype,'DirichletEps',params.dirichleteps);
dat = struct('F',F, 'fr',fr);
