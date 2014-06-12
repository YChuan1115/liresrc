function cvdata_FMD(PATH_TO_FMD, ROOTPATH)
%
% CVDATA_FMD - construct cross-validation set on Flickr Material
%
%  cvdata_FMD(PATH_TO_DATASET, ROOTPATH)
%
% Input:
%  PATH_TO_DATASET - Path to dataset
%  ROOTPATH    - Path to the working directory for the dataset
%
% Output:
%  File 'cv_data_test<01-03>.mat' for evaluation is generated in ROOTPATH.
%

%PATH_TO_DATASET = '/home/nfs3/work/HoGinBoF/data/FMD';
%ROOTPATH = '/home/takumim/tmp2/FMD';

idname = fullfile(PATH_TO_FMD,'image/');

dlist = dir(idname);
dlist(1:2) = [];
iter = 1;
for i = 1:numel(dlist)
	flist = dir(fullfile(idname, dlist(i).name, '*.jpg'));
	for j = 1:numel(flist)
		flists{iter,1} = fullfile(dlist(i).name,flist(j).name);
		ID(iter,1)   = i;
		iter = iter + 1;
	end
end
classes = {dlist.name};

for cvi = 1:3
	CV = cvpartition(ID, 'holdout', 0.5);
	traininds = find(CV.training);
	trainflist = flists(traininds);
	trainID    = ID(traininds);
	testinds  = find(CV.test);
	testflist = flists(testinds);
	testID    = ID(testinds);
	vwtrainflist = trainflist;
	vwtrainID    = trainID;
	save(fullfile(ROOTPATH, sprintf('cv_data_test%02d.mat',cvi)), 'classes','trainflist','trainID','vwtrainflist','vwtrainID','testflist','testID');
end

dirpath = idname;
save(fullfile(ROOTPATH,'imagefiles.mat'), 'flists','dirpath');

%- build mask image -%
mdname = fullfile(PATH_TO_FMD,'mask/');
for i = 1:numel(flists)
	mskimg = imread(fullfile(mdname,flists{i}));
	if size(mskimg,3) > 1
		mskimg = rgb2gray(mskimg);
	end
	mskimg = mskimg>128;
	imwrite(mskimg, [fullfile(idname,flists{i}),'.mask.bmp'], 'bmp');
end
