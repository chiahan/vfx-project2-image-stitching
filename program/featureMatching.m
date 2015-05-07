function match = featureMatching(desc1, desc2, pos1, pos2)

    match = [];

    for i = 1:size(desc1, 1)
        dists = [];
        for j = 1:size(desc2, 1)
            dists = [dists; descriptorDistance(desc1(i,:), desc2(j,:))];
        end
        [min1 min1_idx] = min(dists);
        dists(min1_idx) = [];
        min2 = min(dists);
        %disp(min1);
        %disp(min2);
        if (min1/min2) < 0.8
            match = [match; [i min1_idx]];
        end
    end
end
