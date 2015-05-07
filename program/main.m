function main()
%%%%%%%%%%%%%%
% parameters %
%%%%%%%%%%%%%%
    img_folder = 'grail';
    focal_len = 628; % parrington=704.5 tree=801.5 grail=628 jerry=428 tree2=815.081
    result_output = ['../results/' img_folder '_panorama.png'];
    % harris detector parameters
    sigma = 3;
    w = 5; % parrington=5 grail=5 tree=3
    threshold = 4000; % parrington=4000 grail=4000 tree=500
    k = 0.04;
    % ransac parameters
    threshold = 10;
    % drift erasing parameters
    drift_tag = 0;
%%%%%%%%%%%%%%
% parameters %
%%%%%%%%%%%%%%
    
    img_path = ['../images/' img_folder];
    
    disp('read images');
    [images, img_count, img_h, img_w] = readImages(img_path);
    
    disp('inverse warping (cylindrical projection)');
    [warped_images] = inverseWarping(images, img_count, img_h, img_w, focal_len);
    
    disp('harris corner detection');
    disp('feature description');
    for i = 1:img_count
        [featureX, featureY, R]= harrisDetection(warped_images(:,:,:,i), sigma, w, threshold, k);
%       disp(length(featureX));
        [feature_pos, feature_descriptor] = siftDescriptor(warped_images(:,:,:,i), featureX, featureY);
        features_pos{i} = feature_pos;
        features_desc{i} = feature_descriptor;
%      figure(i);imshow(warped_images(:,:,:,i));
%      hold on
%      plot(features_pos{i}(:,1),features_pos{i}(:,2), 'r*');
    end
     
    disp('feature matching'); 
    disp('RANSAC'); % exclude outlier
    for j = 1:img_count-1
        desc1 = features_desc{j};
        desc2 = features_desc{j+1};
        pos1 = features_pos{j};
        pos2 = features_pos{j+1};
        match = featureMatching(desc1, desc2, pos1, pos2);
        matchInlier = ransac(match, pos1, pos2);
        
        matches{j} = match;
        % disp(matches{j});
        matchInliers{j} = matchInlier;
        % disp(matchInliers{j});
    end
    
    disp('image matching'); % use inliers to count translation amount between images
    drift_y = 0;
    for k = 1:img_count-1
        tran = imageMatching(matchInliers{k}, features_pos{k}, features_pos{k+1});
        trans{k} = tran;
        drift_y = drift_y+trans{k}(2);
    end
    
    disp('solve drift problem');
    if (drift_tag)
        avg_drift_y = round(drift_y / (img_count-1));
    else avg_drift_y = 0;
    end
    
    disp('blending'); % blend images together
    imNow = warped_images(:,:,:,1);
    for l = 2:img_count
        %disp(trans{l-1});        
        imNow = blendImage(imNow, warped_images(:,:,:,l), trans{l-1}, l-1, avg_drift_y);
    end
    imwrite(uint8(imNow), result_output);
    disp('done');
end