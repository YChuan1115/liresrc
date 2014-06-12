function cvdata_caltech256(PATH_TO_DATASET, ROOTPATH)
%
% CVDATA_CALTECH256 - construct cross-validation set on Caltech256 
%
%  cvdata_caltech256(PATH_TO_DATASET, ROOTPATH)
%
% Input:
%  PATH_TO_DATASET - Path to dataset
%  ROOTPATH        - Path to the working directory for the dataset
%
% Output:
%  File 'cv_data_test<151-603>.mat' for evaluation is generated in ROOTPATH.
%

%PATH_TO_DATASET = '/home/takumi/tmp/Caltech256/origdata/256_ObjectCategories/';
%ROOTPATH = '/home/takumi/tmp2/Caltech256/';

dlist = dir(PATH_TO_DATASET);
dlist(1:2) = [];
zind = strmatch('257.clutter',{dlist.name});
dlist(zind) = [];
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
	for trainnum = [15,30,45,60]
		for i = 1:numel(classes)
			inds = find(ID==i);
			rinds= randperm(numel(inds));
			traininds{i} = inds(rinds(1:trainnum));
			testinds{i}  = inds(rinds(trainnum+(1:min(50,numel(rinds)-trainnum))));
		end
		traininds  = cat(1,traininds{:});
		trainflist = flists(traininds);
		trainID    = ID(traininds);
		testinds  = cat(1,testinds{:});
		testflist = flists(testinds);
		testID    = ID(testinds);
		vwtrainflist = trainflist;
		vwtrainID    = trainID;
		save(fullfile(ROOTPATH, sprintf('cv_data_test%d%d.mat',trainnum,cvi)), 'classes','trainflist','trainID','vwtrainflist','vwtrainID','testflist','testID');
		clear train* test* vwtrain*
	end
end

dirpath = PATH_TO_DATASET;
save(fullfile(ROOTPATH,'imagefiles.mat'), 'flists','dirpath');
