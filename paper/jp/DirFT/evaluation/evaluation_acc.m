function result = evaluation_acc(clsresult)
%
% Evaluation based on average accuracy across classes
%
%  result = evaluation_acc(iresult)
%
% Input: 
%  iresult - Classification result structure [#param x 1]
%           .ids     - Test image file names (cell) [n x 1]
%           .classes - Class category names (cell) [1 x #class]
%           .conf    - Classifier output [n x #class]
%           .ID      - ID [n x 1]
%
% Output:
%   result - Evaluation result structure [#param x 1]
%            .macc    - Mean classification accuracy
%            .confmat - Confusion matrix
%

ID = clsresult(1).ID;
n  = size(clsresult(1).conf,1);
if numel(ID) == n
	ncls    = max(ID);
else
	ncls    = size(ID,2);
	[~, ID] = max(ID, [], 2); 
end

result = rmfield(clsresult,{'ids','classes','conf','ID'});
result(1).macc    = [];
result(1).confmat = [];

for ic = 1:numel(result)
	testvals = clsresult(ic).conf;
	[~, estID] = max(testvals, [], 2); 
	confmat = full(sparse(ID, estID, 1, ncls, ncls));
	confmat = bsxfun(@times, confmat, 1./max(sum(confmat,2),eps));
	macc = mean(diag(confmat));
	result(ic).macc    = macc;
	result(ic).confmat = confmat;
end
