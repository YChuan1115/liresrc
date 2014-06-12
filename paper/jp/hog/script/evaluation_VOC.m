function result = evaluation_VOC(rootpath, testmode, headerid)
%
% Evaluation based on VOCcode
%  result = evaluation(headerid)
%
% Input: 
%   The result file is named by '<rootpath>/result/<headerid>_<testmode>.mat'
%
% Output:
%   result - Evaluation result structure [#class x 1]
%            .cost   - Cost parameter
%            .mAP    - mean AP
%            .<category>  - ROC data [char]
%

addpath('./voc');

%- initialize VOC options -%
VOCopts = VOCinit(rootpath,testmode);

%- train and test classifier for each class -%
dat = load(sprintf(VOCopts.clsrespath,headerid),'result');
clsresult = dat.result; clear dat;
result    = struct('mAP',cell(numel(clsresult),1));

%- load ground trugh labels -%
for i = 1:VOCopts.nclasses
	[gtids{i},gt{i}] = textread(sprintf(VOCopts.clsimgsetpath,VOCopts.classes{i},VOCopts.testset),'%s %d');
	if numel(unique(gtids{i})) ~= numel(gtids{i})
		error('multiple image in ground truth for %s',VOCopts.classes{i});
	end
	result(1).(VOCopts.classes{i}) = NaN; 
end

%- compute precision/recall -%
parfor ic = 1:numel(clsresult)
	map = zeros(VOCopts.nclasses,1);
	for i = 1:VOCopts.nclasses
		cls = VOCopts.classes{i};
		[recall,prec,ap] = VOCevalcls(VOCopts,clsresult(ic),cls,gtids{i},gt{i},false);   % compute and display PR

		result(ic).(cls) = struct('class', cls, 'recall',recall, 'prec',prec, 'ap',ap);
		map(i) = ap;
	end
	result(ic).mAP = mean(map);
	result(ic).cost= clsresult(ic).cost;
end
