function cvdata_landuse(PATH_TO_DATASET, ROOTPATH)
%
% CVDATA_LANDUSE - construct cross-validation set on Land-Use dataset
%
%  cvdata_landuse(PATH_TO_DATASET, ROOTPATH)
%
% Input:
%  PATH_TO_DATASET - Path to dataset
%  ROOTPATH    - Path to the working directory for the dataset
%
% Output:
%  File 'cv_data_test<01-05>.mat' for evaluation is generated in ROOTPATH.
%

%PATH_TO_DATASET = '/home/nfs3/work/HoGinBoF/data/LandUse/Images';
%ROOTPATH = '/home/takumi/tmp2/LandUse/';

dlist = dir(PATH_TO_DATASET);
dlist(1:2) = [];
iter = 1;
for i = 1:numel(dlist)
	flist = dir(fullfile(PATH_TO_DATASET, dlist(i).name, '*.tif'));
	for j = 1:numel(flist)
		flists{iter,1} = fullfile(dlist(i).name,flist(j).name);
		ID(iter,1)   = i;
		iter = iter + 1;
	end
end
classes = {dlist.name};

CV = cvpartition(ID, 'kfold', 5);

for cvi = 1:CV.NumTestSets
	traininds  = find(CV.training(cvi));
	trainflist = flists(traininds);
	trainID    = ID(traininds);
	testinds  = find(CV.test(cvi));
	testflist = flists(testinds);
	testID    = ID(testinds);
	vwtrainflist = trainflist;
	vwtrainID    = trainID;
	save(fullfile(ROOTPATH, sprintf('cv_data_test%02d.mat',cvi)), 'classes','trainflist','trainID','vwtrainflist','vwtrainID','testflist','testID');
	clear train* test* vwtrain*
end

dirpath = PATH_TO_DATASET;
save(fullfile(ROOTPATH,'imagefiles.mat'), 'flists','dirpath');
