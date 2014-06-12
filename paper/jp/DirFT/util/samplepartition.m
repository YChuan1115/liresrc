function splits = samplepartition(n, nsplit)

if nsplit > 1
	splits = cvpartition(n, 'kfold', nsplit);
else
	splits = cvpartition(n, 'resubstitution');
end	