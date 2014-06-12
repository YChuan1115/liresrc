function cvdata_CUB2011(PATH_TO_DATASET, ROOTPATH)
%
% CVDATA_CUB2011 - construct cross-validation set on CUB_200_2011 Dataset
%
%  cvdata_CUB2011(PATH_TO_DATASET, ROOTPATH)
%
% Input:
%  PATH_TO_DATASET - Path to dataset, e.g., 'CUB2011/CUB_200_2011'
%  ROOTPATH    - Path to the working directory for the dataset
%
% Output:
%  File 'cv_data_test.mat' for evaluation is generated in ROOTPATH.
%

%PATH_TO_DATASET = '/home/nfs3/work/HoGinBoF/data/CUB_200_2011';
%ROOTPATH = '/home/takumi/tmp2/CUB2011/';

idname = fullfile(PATH_TO_DATASET,'images/');

[clsid, classes] = textread(fullfile(PATH_TO_DATASET, 'classes.txt'), '%d %s');
ncls = numel(classes);

[counts, flists] = textread(fullfile(PATH_TO_DATASET, 'images.txt'), '%d %s');
[counts_, ID]    = textread(fullfile(PATH_TO_DATASET, 'image_class_labels.txt'), '%d %d');
if any(counts ~= counts_), error('mismatch in images.txt and image_class_labels.txt'); end

A = load(fullfile(PATH_TO_DATASET,'train_test_split.txt'));
if any(counts ~= A(:,1)), error('mismatch in images.txt and train_test_split.txt'); end
trainidx = A(:,2) > 0;
testidx  = ~trainidx;

trainflist = flists(trainidx);
trainID    = ID(trainidx);
vwtrainflist = trainflist;
vwtrainID    = trainID;
testflist = flists(testidx);
testID    = ID(testidx);
save(fullfile(ROOTPATH, 'cv_data_test.mat'), 'classes','trainflist','trainID','vwtrainflist','vwtrainID','testflist','testID');

dirpath = idname;
save(fullfile(ROOTPATH,'imagefiles.mat'), 'flists','dirpath');
