function [rec,prec,ap] = VOCevalcls(VOCopts,dat,cls,gtids,gt,draw)

%- load results -%
[ids,confidence] = deal(dat.ids, dat.conf(:,strmatch(cls, dat.classes)));

%- map results to ground truth images -%
[~,loc] = ismember(regexprep(ids,'\.jpg',''), gtids);
if any(loc==0)
	error('unrecognized image in test set');
end
out = -Inf(size(gt));
out(loc) = confidence;

%- compute precision/recall -%
[so,si] = sort(out,'descend');
tp = gt(si)>0;
fp = gt(si)<0;

fp = cumsum(fp);
tp = cumsum(tp);
rec  = reshape(tp/sum(gt>0),[],1);
prec = reshape(tp./(fp+tp),[],1);

%- compute average precision -%
ap = mean(max(repmat(prec,1,11).*bsxfun(@ge,rec,(0:0.1:1)),[],1));
%ap=0;
%for t=0:0.1:1
%    p=max(prec(rec>=t));
%    if isempty(p)
%        p=0;
%    end
%    ap=ap+p/11;
%end

if draw
    %- plot precision/recall -%
    plot(rec,prec,'-');
    grid;
    xlabel 'recall'
    ylabel 'precision'
    title(sprintf('class: %s, subset: %s, AP = %.3f',cls,VOCopts.testset,ap));
end
