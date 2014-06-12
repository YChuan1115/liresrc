function VOCopts = VOCinit(rootpath,testset)

VOCopts.dataset = rootpath;

% get current directory with forward slashes

% change this path to point to your copy of the PASCAL VOC data
VOCopts.datadir = rootpath;

% initialize the test set
VOCopts.testset = testset;

% initialize main challenge paths
VOCopts.clsimgsetpath= fullfile(VOCopts.datadir, 'origdata/Labels/%s_%s.txt');
VOCopts.clsrespath=fullfile(VOCopts.datadir, 'result', ['/%s_' VOCopts.testset '.mat']);

% initialize the VOC challenge options

VOCopts.classes={...
	'aeroplane'
	'bicycle'
	'bird'
	'boat'
	'bottle'
	'bus'
	'car'
	'cat'
	'chair'
	'cow'
	'diningtable'
	'dog'
	'horse'
	'motorbike'
	'person'
	'pottedplant'
	'sheep'
	'sofa'
	'train'
	'tvmonitor'};


VOCopts.nclasses=length(VOCopts.classes);	
