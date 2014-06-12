function cvdata_UIUCsports(PATH_TO_DATASET, ROOTPATH)
%
% CVDATA_UIUCSPORTS - construct cross-validation set on UIUC-Sports
%
%  cvdata_UIUCsports(PATH_TO_DATASET, ROOTPATH)
%
% Input:
%  PATH_TO_DATASET - Path to dataset
%  ROOTPATH    - Path to the working directory for the dataset
%
% Output:
%  File 'cv_data_test<01-03>.mat' for evaluation is generated in ROOTPATH.
%

%PATH_TO_DATASET = '/home/nfs3/work/HoGinBoF/data/UIUCsports';
%ROOTPATH = '/home/takumi/tmp2/UIUCsports/';

dlist = dir(PATH_TO_DATASET);
dlist(1:2) = [];
iter = 1;
for i = 1:numel(dlist)
	flist = dir(fullfile(PATH_TO_DATASET, dlist(i).name, '*.jpg'));
	for j = 1:numel(flist)
		flists{iter,1} = fullfile(dlist(i).name,flist(j).name);
		ID(iter,1)   = i;
		iter = iter + 1;
	end
end
classes = {dlist.name};

for cvi = 1:3
	for i = 1:numel(classes)
		inds = find(ID==i);
		rinds= randperm(numel(inds),70+60);
		traininds{i} = inds(rinds(1:70));
		testinds{i}  =  inds(rinds(71:end));
	end
	traininds  = cat(1,traininds{:});
	trainflist = flists(traininds);
	trainID    = ID(traininds);
	testinds  = cat(1,testinds{:});
	testflist = flists(testinds);
	testID    = ID(testinds);
	vwtrainflist = trainflist;
	vwtrainID    = trainID;
	save(fullfile(ROOTPATH, sprintf('cv_data_test%02d.mat',cvi)), 'classes','trainflist','trainID','vwtrainflist','vwtrainID','testflist','testID');
	clear train* test* vwtrain*
end

dirpath = PATH_TO_DATASET;
save(fullfile(ROOTPATH,'imagefiles.mat'), 'flists','dirpath');
