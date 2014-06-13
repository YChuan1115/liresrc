function PATH_TO_IMAGES = convert_15scene(PATH_TO_DATASET, ROOTPATH)
%
% CONVERT_15SCENE - reconstruct dataset
%
%  PATH_TO_IMAGES = convert_15scene(PATH_TO_DATASET, ROOTPATH)
%
% Input:
%  PATH_TO_DATASET - Path to dataset which contains images in each 'object' sub-directory,
%                    such as <15scene>/outdoor/*.jpg
%                                     /indoor/*.jpg
%                                     :
%  ROOTPATH - Path to the working directory for the dataset
%
% Output:
%  PATH_TO_IMAGES - Path to the directory that contains copied images of the dataset
%  and
%  Files 'cv_data_test*.mat' for cross-validations are generated in ROOTPATH.
%

PATH_TO_IMAGES = fullfile(ROOTPATH, 'images');

dlist = dir(PATH_TO_DATASET);
dlist(1:2) = [];

ncls = numel(dlist);

%- Copy and rename image files -%
count = 1;
for i = 1:numel(dlist)
	flist = dir(fullfile(PATH_TO_DATASET, dlist(i).name, '*.jpg'));
	for j = 1:numel(flist)
		fname = sprintf('%06d',count);
		copyfile(fullfile(PATH_TO_DATASET,dlist(i).name,flist(j).name), sprintf('%s/images/%s.jpg', ROOTPATH, fname));
		ID(count) = i;
		names{count} = fname;
		count = count + 1;
	end
end

classes = {dlist.name};

%- CV data -%
for cvi = 1:10
	rng(cvi);
	CV = equalcvpartition(ID, 100);
	trainflist = names(CV.test);
	trainID    = full(sparse(1:nnz(CV.test), ID(CV.test), 2, nnz(CV.test),ncls)) - 1;
	vwtrainflist = trainflist;
	vwtrainID    = trainID;
	testflist = names(CV.training);
	testID    = full(sparse(1:nnz(CV.training), ID(CV.training), 2, nnz(CV.training),ncls)) - 1;
	save(fullfile(ROOTPATH, sprintf('cv_data_test%d.mat',cvi)), ...
			'classes','trainflist','trainID','vwtrainflist','vwtrainID','testflist','testID');
end
