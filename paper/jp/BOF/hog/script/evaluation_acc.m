function res = evaluation_acc(dataname, testmode, headerid)
%
% Compute average accuracy across classes
%  result = evaluation_acc(dataname, headerid, testmode)
%
% Input: 
%   The result file is named by '~/tmp/<dataname>/<headerid>_<testmode>.mat'
%
% Output:
%   result - Evaluation result structure [#param x 1]
%            .cost  - Cost parameter
%            .macc  - Mean classification accuracy
%            .confmat - Confusion matrix
%

load(sprintf('/home/takumi/tmp/%s/result/%s_%s.mat',dataname,headerid,testmode));
load(sprintf('/home/takumi/tmp/%s/cv_data_%s.mat',dataname,testmode));

ncls = numel(classes);

res = struct('cost',cell(numel(result),1), 'macc',[], 'confmat',[]);

for ic = 1:numel(result)
	testvals = result(ic).conf;
	[~, ID]    = max(testID, [], 2); 
	[~, estID] = max(testvals, [], 2); 
	confmat = full(sparse(ID, estID, 1, ncls, ncls));
	confmat = bsxfun(@times, confmat, 1./sum(confmat,2));
	macc = mean(diag(confmat));
	res(ic).macc = macc;
	res(ic).confmat = confmat;
	res(ic).cost = result(ic).cost;
end
