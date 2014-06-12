function ohash = struct2hash(x, varargin)

if ~isstruct(x)
	ofname = [];
else
	fnames = fieldnames(x);
	fnames = setdiff(fnames, varargin);

	ofnames = fnames;
	for i = 1:numel(fnames)
		y = x.(fnames{i});
		switch(class(y))
		case 'char'
			ofnames{i} = [ofnames{i}, y, '_'];
		case 'double'
			if all(y==floor(y))
				ofnames{i} = [ofnames{i}, sprintf('%d-',y)];
			else
				ofnames{i} = [ofnames{i}, sprintf('%g-',y)];
			end
			ofnames{i}(end) = '_';
		case 'logical'
			ofnames{i} = [ofnames{i}, sprintf('%d-',y)];
			ofnames{i}(end) = '_';
		case 'function_handle'
			ofnames{i} = [ofnames{i}, regexprep(func2str(y),{'\@\([\w\,]+\)','\/','*','(',')'},{'','_','','',''}),'_'];
		case 'cell'
			ofnames{i} = [ofnames{i}, sprintf('%g-',cell2mat(y))];
			ofnames{i}(end) = '_';
		otherwise
			error('type of %s is not supported.',class(y));
		end
	end
	ofname = cat(2,ofnames{:});
	if ofname(end)=='_'
		ofname(end) = [];
	end
end

if isempty(ofname)
	ohash = [];
else
	ohash  = sum(double(uint8(ofname)));
end

