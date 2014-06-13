costs = [1:9,10:10:100];
nword = 256;
classify;
clearvars -except ROOTPATH testtype nword featparams;

fname = sprintf('result_gradpca_exp-10_262144x_tau%1.1f-KTPCk%d_word%d_size16-24-32-',featparams.tau,featparams.kNNword,nword); 
disp(fname);
performances = evaluation_VOC(ROOTPATH, testtype, fname); % for VOC protocol (mean AP)
%performances = evaluation_acc(ROOTPATH, testtype, fname); % for accuracy
save('-v7.3', fullfile(ROOTPATH, 'result', sprintf('%s_%s.mat',fname,testtype)), 'performances', '-append');
