addpath('../util/');
addpath('../myvlfeat/toolbox/');
vl_setup;

matlabpool open;

ROOTPATH = '/home/nfs/work/tmp/VOC2007';
PATH_TO_DATASET = '/home/nfs/work/DualLinear/data/PASCAL_VOC/2007/VOCdevkit/VOC2007/';

cvdata_VOC(PATH_TO_DATASET, ROOTPATH);

testtype = 'test';

params.nword     = 16384;
params.localdesc = struct('calc_desc',@calc_phow, 'step',4, 'patchsizes',[16,24,32], 'floatdescriptors',0, 'normalizationtype',1);
params.feat      = struct('nposbins',{{[1;3],[2;2],[1;1]}}, 'codekNN',20, 'chunksize',10000,'savefeat',false);
params.classifier= struct('cost',1:0.1:3);

addpath('../localdesc');
build_codebook;   clearvars -except PATH_TO_DATASET ROOTPATH testtype params

addpath('../classify');
build_bow_classification;

addpath('../evaluation');
result_mAP = evaluation_voc(PATH_TO_DATASET, result);
save(fullfile(opath, sprintf('result_%dword_%d_%d_%d_%s.mat', nword, struct2hash(lparams), struct2hash(fparams), struct2hash(cparams), testtype)),'result_mAP','-append');

fprintf('acc.=%2.2f%%\n',100*max([result_mAP.mAP]));
