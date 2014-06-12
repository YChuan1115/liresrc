function result = evaluation_voc(dataname, clsresult)
%
% Evaluation based on VOCcode (mean AP)
%
%  result = evaluation_voc(PATH_TO_VOC, result)
%
% Input: 
%  PATH_TO_VOC - Path to VOC dataset, e.g., 'VOCdevkit/VOC2007'
%  result      - Classification result structure [#param x 1]
%                .ids     - Test image file names (cell) [n x 1]
%                .classes - Class category names (cell) [1 x #class]
%                .conf    - Classifier output [n x #class]
%                .ID      - ID [n x #class]
%
% Output:
%   result - Evaluation result structure [#param x 1]
%            .mAP         - mean AP
%            .<category>  - ROC data [char]
%

%- initialize VOC options -%
VOCopts = VOCinit(dataname,'test');

%- train and test classifier for each class -%
result = rmfield(clsresult,{'ids','classes','conf','ID'});
result(1).mAP = [];

%- load ground trugh labels -%
for i = 1:VOCopts.nclasses
	[gtids{i},gt{i}] = textread(sprintf(VOCopts.clsimgsetpath,VOCopts.classes{i},VOCopts.testset),'%s %d');
	if numel(unique(gtids{i})) ~= numel(gtids{i})
		error('multiple image in ground truth for %s',VOCopts.classes{i});
	end
	result(1).(VOCopts.classes{i}) = []; 
end

%- compute average precision -%
parfor ic = 1:numel(result)
	map = zeros(VOCopts.nclasses,1);
	for i = 1:VOCopts.nclasses
		cls = VOCopts.classes{i};
		[recall,prec,ap] = VOCevalcls(VOCopts,clsresult(ic),cls,gtids{i},gt{i},false);   % compute and display PR
		result(ic).(cls) = struct('class', cls, 'recall',recall, 'prec',prec, 'ap',ap);
		map(i) = ap;
	end
	result(ic).mAP = mean(map);
end
