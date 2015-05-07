function imout = blendImage(im1, im2, trans, step, drift_y)

    % assumption
    %   trans = [dX, dY]; dX < 0;
    %   im1 and im2 are 3-channel images.
    
    [row1, col1, channel] = size(im1);    
    [row2, col2, channel] = size(im2);
    
    imout = zeros(ceil(row2*1.5), col1+abs(trans(1)), channel);
    %imshow(im1);imshow(im2);
    blendWidth = col2 - trans(1);
    
    % r1 & r2 are alpha layers.
    r1 = ones(1, col1);
    r2 = ones(1, col2);
    r1(1, 1:blendWidth+1) = [0:(1/blendWidth):1];
    r2(1, (end-blendWidth):end) = [1:(-1/blendWidth):0];

    % premultiply im1, im2 by r1, r2
    bim1 = double(im1);
    bim2 = double(im2);
    for c = 1:channel
        for y = 1:row1
            bim1(y,:,c) = bim1(y,:,c) .* r1;
        end
        for y = 1:row2
            bim2(y,:,c) = bim2(y,:,c) .* r2;
        end
    end

    % merge by 'plus'
    if step==1
    for y = 1:row1
        for x = 1:col1
            imout(y+floor(row2/4)+trans(2)-drift_y,x+trans(1),:) = bim1(y,x,:);            
        end
    end
    else
        for y = 1:row1
        for x = 1:col1
            if (y+trans(2)-drift_y)>0
            imout(y+trans(2)-drift_y,x+trans(1),:) = bim1(y,x,:);            
            end
        end
    end
    end    
    for y = 1:row2
        for x = 1:col2 
            if bim2(y,x,:)~=0 imout(y+floor(row2/4),x,:) = imout(y+floor(row2/4),x,:) + bim2(y,x,:); end
            %if bim2(y,x,:)~=0 imout(y+floor(row2/4),x,:) = bim2(y,x,:); end
        end
    end
    %imout(find(imout<0)) = 0;
    %imout(find(imout>255)) = 255;
end
