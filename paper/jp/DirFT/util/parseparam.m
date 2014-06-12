function params = parseparam(params, varargin)

prmnames = fieldnames(params);
[pidx, loc] = ismember(lower(prmnames), lower(varargin(1:2:end)));
for i = 1:length(loc)
	if loc(i) > 0
		if iscell(params.(prmnames{i}))
			varargin{2*loc(i)} = {params.(prmnames{i})};
		else
			varargin{2*loc(i)} = params.(prmnames{i});
		end
	end
end
params = struct(varargin{:});
