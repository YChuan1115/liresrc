%- SIFT by vlfeat -%
%- Each component must be divided by 512 to get original 'double' precision -%
addpath(PATH_TO_VLFEAT);
vl_setup;

%- Path -%
opath = fullfile(ROOTPATH,'phow_desc'); mkdir(opath);

%- Func. -%
savefeat = @(fname, F,fr,patchsizes,step,Lh,Lw,toc) save(fname, 'F','fr','patchsizes','step','Lh','Lw','toc');

%- Parameters -%
step = 4;
patchsizes = [16,24,32];
footer = sprintf('%d-',patchsizes);

flist = dir(fullfile(PATH_TO_IMAGES,'*.jpg'));

for i = 1:length(flist)
	img = imread(fullfile(PATH_TO_IMAGES,flist(i).name));
	img = im2single(img) ;

%	%- standarize image -%
%	if size(img,1) > 480, img = imresize(img, [480 NaN]) ; end

	%- SIFT -%
	ftic = tic;
	[fr F] = vl_phow(img, 'Sizes',patchsizes/4, 'Step',step);
	ftoc = toc(ftic);
	Lh = length(unique(fr(2,:)));
	Lw = length(unique(fr(1,:)));
	savefeat(fullfile(opath, regexprep(flist(i).name,'.jpg',sprintf('_PHOW_size%s.mat',footer))), F,fr,patchsizes,step,Lh,Lw,ftoc);
end
rmpath(PATH_TO_VLFEAT);
