function output_VOCresults(rootpath, testmode, headerid, ic)

% initialize VOC options
VOCopts = VOCinit(rootpath,testmode);

% train and test classifier for each class
dat = load(sprintf(VOCopts.clsrespath,headerid),'result');
clsresult = dat.result; clear dat;

odir = fullfile(rootpath,'submission/Main');
if exist(odir, 'dir') == 0
	mkdir(odir);
end

map = zeros(VOCopts.nclasses,1);
for i = 1:VOCopts.nclasses
	cls = VOCopts.classes{i};
	fid = fopen(fullfile(odir, sprintf('comp1_cls_%s_%s.txt',testmode,cls)),'w');
	[ids,confidence] = deal(clsresult(ic).ids, clsresult(ic).conf(:,strmatch(cls, clsresult(ic).classes)));
	for j = 1:numel(ids)
		fprintf(fid,'%11s %f\n', ids{j}, confidence(j));
	end
	fclose(fid);
end
