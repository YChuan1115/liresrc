function cvdata_SUN397(PATH_TO_DATASET, ROOTPATH)
%
% CVDATA_SUN397 - construct cross-validation set on SUN-397 dataset
%
%  cvdata_SUN397(PATH_TO_DATASET, ROOTPATH)
%
% Input:
%  PATH_TO_DATASET - Path to dataset
%  ROOTPATH    - Path to the working directory for the dataset
%
% Output:
%  File 'cv_data_test.mat' for evaluation is generated in ROOTPATH.
%

%PATH_TO_DATASET = '/home/takumi/tmp2/SUN_scene/origdata';
%ROOTPATH = '/home/takumi/tmp2/SUNscene/';

classes = textread(fullfile(PATH_TO_DATASET,'Partitions/ClassName.txt'),'%s');

flists = [];
for i = 1:10
	trainflists{i} = textread(fullfile(PATH_TO_DATASET,sprintf('Partitions/Training_%02d.txt',i)),'%s');
	testflists{i}  = textread(fullfile(PATH_TO_DATASET,sprintf('Partitions/Testing_%02d.txt',i)),'%s');
	flists = union(flists,[trainflists{i};testflists{i}]);
end

ID = zeros(numel(flists),1);
for iter = 1:numel(flists)
	filename = flists{iter};
	dirname  = fileparts(filename);
	id = strmatch(dirname, classes, 'exact');
	if isempty(id), error('wrong class name.'); end;
	ID(iter) = id;
end

for iset = 1:10
	trainflist = trainflists{iset};
	[~, loc]   = ismember(trainflists{iset}, flists);
	trainID    = ID(loc);

	testflist = testflists{iset};
	[~, loc]  = ismember(testflists{iset}, flists);
	testID    = ID(loc);

	vwtrainflist = trainflist;
	vwtrainID    = trainID;

	save(fullfile(ROOTPATH, sprintf('cv_data_test%02d.mat',iset)), 'classes','trainflist','trainID','vwtrainflist','vwtrainID','testflist','testID');
	clear trainflist trainID testflist testID;
end

dirpath = fullfile(PATH_TO_DATASET,'SUN397');
save(fullfile(ROOTPATH,'imagefiles.mat'), 'flists','dirpath');
