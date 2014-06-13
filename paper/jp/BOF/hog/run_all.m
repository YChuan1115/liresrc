ROOTPATH = ; %indicate path that contains your dataset

PATH_TO_IMAGES = ; %indicate  path of the images
PATH_TO_VLFEAT = ; %path to vlfeat toolbox

%- SIFT -%
cd ./localdesc/;
	calc_phow;       clearvars -except ROOTPATH; 
%- Visualwords -%
testtype = 'test';
	visualword_phow; clearvars -except ROOTPATH testtype;
	cd ../;

%- Basis for orientation coding of p.d.f gradients -%
cd ./pdfgrad/; 
	pca_pdfgrad; clearvars -except ROOTPATH testtype;
	cd ../;

%- Image classification -%
cd ./script/; 
	run_classification;
	cd ../;
