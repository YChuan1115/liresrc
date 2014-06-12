function cvdata_VOC(PATH_TO_VOC, ROOTPATH)
%
% CVDATA_VOC - construct cross-validation set on VOC
%
%  cvdata_VOC(PATH_TO_VOC, ROOTPATH)
%
% Input:
%  PATH_TO_VOC - Path to VOC dataset, e.g., 'VOCdevkit/VOC2007'
%  ROOTPATH    - Path to the working directory for the dataset
%
% Output:
%  File 'cv_data_test.mat' for cv evaluation is generated in ROOTPATH.
%

%PATH_TO_VOC = '/home/nfs/work/DualLinear/data/PASCAL_VOC/2007/VOCdevkit/VOC2007/';

dname = fullfile(PATH_TO_VOC,'ImageSets/Main/');
list  = dir(fullfile(dname,'*_trainval.txt'));
suffixes = {'_trainval.txt', '_test.txt', '_train.txt'};

classes = arrayfun(@(x) regexprep(x.name,'_trainval.txt', ''), list, 'UniformOutput',false);

sets = struct('flist',cell(numel(suffixes),1), 'ID',[]);
for j = 1:numel(suffixes)
	fnames = cellfun(@(x) [x, suffixes{j}], classes, 'UniformOutput',false);
	[flist, ~] = textread(fullfile(dname,fnames{1}),'%s %d');
	ID = zeros(numel(flist), numel(list));
	for i = 1:numel(list)
		[flist_, id] = textread(fullfile(dname,fnames{i}),'%s %d');
		if ~all(cellfun(@(x,y) strcmp(x,y), flist, flist_)), error('wrong file order.'); end
		ID(:,i) = id;
	end
	flist   = cellfun(@(x) [x, '.jpg'], flist, 'UniformOutput',false);
	sets(j) = struct('flist',{flist}, 'ID',ID);
end
trainflist = sets(1).flist;
trainID    = sets(1).ID;
testflist  = sets(2).flist;
testID     = sets(2).ID;
vwtrainflist = sets(3).flist;
vwtrainID    = sets(3).ID;

save(fullfile(ROOTPATH,'cv_data_test.mat'), 'trainflist','trainID','testflist','testID','vwtrainflist','vwtrainID','classes');

flists = cat(1, vwtrainflist, trainflist, testflist);
dirpath= fullfile(PATH_TO_VOC,'JPEGImages');
save(fullfile(ROOTPATH,'imagefiles.mat'), 'flists','dirpath');
