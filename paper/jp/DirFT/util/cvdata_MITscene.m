function cvdata_MITscene(PATH_TO_DATASET, ROOTPATH)
%
% CVDATA_MITSCENE - construct cross-validation set on MIT-IndoorScene
%
%  cvdata_MITscene(PATH_TO_DATASET, ROOTPATH)
%
% Input:
%  PATH_TO_DATASET - Path to dataset
%  ROOTPATH    - Path to the working directory for the dataset
%
% Output:
%  File 'cv_data_test.mat' for evaluation is generated in ROOTPATH.
%

%PATH_TO_DATASET = '/home/nfs3/work/HoGinBoF/data/IndoorScene/';

fid = fopen(fullfile(PATH_TO_DATASET,'TrainImages.txt'),'r');
iter = 1;
while(1)
	tline = fgetl(fid);
	if ~ischar(tline), break, end
	trainflist{iter,1} = tline;
	iter = iter + 1;
end
fid = fopen(fullfile(PATH_TO_DATASET,'TestImages.txt'),'r');
iter = 1;
while(1)
	tline = fgetl(fid);
	if ~ischar(tline), break, end
	testflist{iter,1} = tline;
	iter = iter + 1;
end

traindirs = cellfun(@(x) fileparts(x), trainflist, 'UniformOutput',false);
testdirs  = cellfun(@(x) fileparts(x), testflist,  'UniformOutput',false);

classes = unique(traindirs);
ncls    = numel(classes);
[~,trainID] = ismember(traindirs,classes);
[~,testID]  = ismember(testdirs, classes);

vwtrainflist = trainflist;
vwtrainID    = trainID;

save(fullfile(ROOTPATH, 'cv_data_test.mat'), 'classes','trainflist','trainID','vwtrainflist','vwtrainID','testflist','testID');

flists = cat(1,trainflist,testflist);
dirpath= fullfile(PATH_TO_DATASET,'Images');
save(fullfile(ROOTPATH,'imagefiles.mat'), 'flists','dirpath');
