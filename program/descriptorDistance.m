function dist = descriptorDistance(desc1, desc2)
    dist = sqrt(sum((desc1 - desc2) .^ 2));
end
