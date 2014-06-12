function convert_VOC(PATH_TO_VOC, ROOTPATH)
%
% CONVERT_VOC - reconstruct VOC dataset
%
%  convert_VOC(PATH_TO_VOC, ROOTPATH)
%
% Input:
%  PATH_TO_VOC - Path to VOC dataset which contains 'origdata', and so on
%  ROOTPATH    - Path to the working directory for the dataset
%
% Output:
%  File 'cv_data_test.mat' for evaluation is generated in ROOTPATH.
%

dname = fullfile(PATH_TO_VOC,'origdata/Labels/');
list  = dir(fullfile(dname,'*_trainval.txt'));
suffixes = {'_trainval.txt', '_test.txt', '_train.txt'};
ofname = 'cv_data_test';

classes = arrayfun(@(x) regexprep(x.name,'_trainval.txt', ''), list, 'UniformOutput',false);

for j = 1:numel(suffixes)
	fnames = cellfun(@(x) [x, suffixes{j}], classes, 'UniformOutput',false);
	[flist, id] = textread(fullfile(dname,fnames{1}),'%s %d');
	ID= zeros(numel(flist), numel(list));
	for i = 1:numel(list)
		[flist_, id] = textread(fullfile(dname,fnames{i}),'%s %d');
		if ~all(cellfun(@(x,y) strcmp(x,y), flist, flist_)), error('wrong file order.'); end
		ID(:,i) = id;
	end
	sets(j) = struct('flist',{flist}, 'ID',ID);
end
trainflist = sets(1).flist;
trainID    = sets(1).ID;
testflist  = sets(2).flist;
testID     = sets(2).ID;
vwtrainflist = sets(3).flist;
vwtrainID    = sets(3).ID;

save(fullfile(ROOTPATH,ofname), 'trainflist','trainID','testflist','testID','vwtrainflist','vwtrainID','classes');
