function maxMatch = ransac(match, pos1, pos2, threshold)
    
    
	p = 0.5;
	n = 2;
	P = 0.9999;
    k = ceil(log(1-P)/log(1-p^n));
    
    N = size(match, 1);
    %disp('N');disp(N);
    
    maxMatch = [];
    if N <= n
	maxMatch = match;
	return;
    end

    % run k times
    for trial = 1:k
	% draw n samples randomly
	pool = randperm(N);
	sampleIdx = pool(1:n);

	sampleMatch = match(sampleIdx, :);
	otherMatch = match;
	otherMatch(sampleIdx, :) = [];

	samplePos1 = pos1(sampleMatch(:,1), :);
	samplePos2 = pos2(sampleMatch(:,2), :);
	othersPos1 = pos1(otherMatch(:,1), :);
	othersPos2 = pos2(otherMatch(:,2), :);

	% fit parameters theta with these n samples
	tmpMatch = [];
	posDiff = samplePos1 - samplePos2;
	theta = mean(posDiff);

	% for each of other N-n points, calcuate 
	% its distance to the fitted model, count the
	% number of inliner points, c
	for i = 1:size(othersPos1, 1)
	    d = (othersPos1(i,:)-othersPos2(i,:)) - theta;
	    if sqrt(sum(d.^2)) < threshold
		tmpMatch = [tmpMatch; otherMatch(i, :)];
	    end
	end
	if size(tmpMatch, 1) > size(maxMatch, 1)
	    maxMatch = tmpMatch;
	end
    end
    
    %disp('ransac_N');disp(size(maxMatch,1));
end
