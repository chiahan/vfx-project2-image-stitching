function [pos, desc] = siftDescriptor(im, featureX, featureY)
    pos = [];
    orient = [];
    desc = [];

    % convert the im into luminance
    dim = ndims(im);
    if( dim == 3 )
        I = rgb2gray(im);
    else
        I = im;
    end
    [row, col] = size(I);

    % convert the image to double
    I = double(I);

    % gaussian-smoothed the image to remove some noise in advance
    L = imfilter(I,fspecial('gaussian',[10 10],1.5));
    
    % Compute x and y derivatives using pixel differences
    %   the first and the last elements are ignored to ease the computing.
    %	that is, it ranges from 2:(end-1)
    Dx = 0.5*(L(2:(end-1), 3:(end)) - L(2:(end-1), 1:(end-2)));
    Dy = 0.5*(L(3:(end), 2:(end-1)) - L(1:(end-2), 2:(end-1)));

    % Compute the magnitude of the gradient
    mag = zeros(size(I));
    mag(2:(end-1), 2:(end-1)) = sqrt(Dx.^2 + Dy.^2);

    % Compute the orientation of the gradient
    %   range: [-pi, pi)
    %	pi is not included to fit hist_orient
    grad = zeros(size(I));
    grad(2:(end-1), 2:(end-1)) = atan2( Dy, Dx );
    grad(find(grad == pi)) = -pi;

    % Set up the histogram bin centers for a 36 bin histogram.
    %   Columns 1 through 13:
    %   -3.14159  -2.96706  -2.79253  -2.61799  -2.44346  -2.26893  -2.09440  -1.91986  -1.74533  -1.57080  -1.39626  -1.22173  -1.04720
    %   Columns 14 through 26:
    %   -0.87266  -0.69813  -0.52360  -0.34907  -0.17453   0.00000   0.17453   0.34907   0.52360   0.69813   0.87266   1.04720   1.22173
    %   Columns 27 through 36:
    %   1.39626   1.57080   1.74533   1.91986   2.09440   2.26893   2.44346   2.61799   2.79253   2.96706
    num_bins = 36;
    hist_step = 2*pi/num_bins;
    %hist_orient = [-pi:hist_step:(pi-hist_step)];
    hist_orient_edge=[-pi:hist_step:pi]; % element# : 37
    hist_orient=[-pi+hist_step/2:hist_step:(pi-hist_step/2)]; % element# : 36

    % Create a gaussian weighting mask
    %   sigma = 1.5 * scale of the keypoint!
    sigma = 1.5;   % FIXME scale=1 when used harris feature detection
    sz = 9;	    % FIXME
    hf_sz = floor(sz/2);
    g = fspecial('gaussian', [sz sz], sigma);
   
    %featureX_ = [];
    %featureY_ = [];
    Orientation_ = [];
    
    for k = 1:numel(featureY)
        % Histogram the gradient orientations for this keypoint weighted by the
        % gradient magnitude and the gaussian weighting mask.
        x = featureX(k);
        y = featureY(k);
        if (x-hf_sz)<1 | (x+hf_sz)>size(I,2) | (y-hf_sz)<1 | (y+hf_sz)>size(I,1) 
            continue;
        end
        %disp([y, x]);
        weightedMag = g.* mag((y-hf_sz):(y+hf_sz),(x-hf_sz):(x+hf_sz));
        orient_window = grad((y-hf_sz):(y+hf_sz),(x-hf_sz):(x+hf_sz));
        
        % Accumulate the histogram bins
        orient_hist = zeros(numel(hist_orient),1);
        hist = vl_whistc(reshape(orient_window,1,[]),reshape(weightedMag,1,[]),hist_orient_edge);
        
        % Find 1 or 2 peaks in the orientation histogram     
        % Extract the value and index of the 1st (largest) peak. 
        first_peak_val = max(hist);
        first_peak_index = find( hist==first_peak_val );
        %featureX_(end+1)=x;
        %featureY_(end+1)=y;
        pos = [pos;[x y]];
        Orientation_(end+1) = hist_orient(first_peak_index);
        
        
        % find 2nd peak if its value over 80% of the largest peak and add keypoints with
        % the orientation corresponding to 2nd peaks to the keypoint list.
        second_peak_val = max(hist(hist~=max(hist)));
        second_peak_index = find( hist==second_peak_val );
        if(second_peak_val > first_peak_val*0.8) 
        %featureX_(end+1) = x;
        %featureY_(end+1) = y;
        pos = [pos;[x y]];
        Orientation_(end+1) = hist_orient(second_peak_index);
        end
    end
    % The final of the SIFT algorithm is to extract feature descriptors for the keypoints.
    % The descriptors are a grid of gradient orientation histograms, where the sampling
    % grid for the histograms is rotated to the main orientation of each keypoint.  The
    % grid is a 4x4 array of 4x4 sample cells of 8 bin orientation histograms.  This 
    % procduces 128 dimensional feature vectors.

    % The orientation histograms have 8 bins
    orient_bin_spacing = pi/4;
    orient_angles = [-pi:orient_bin_spacing:(pi-orient_bin_spacing)];
    window_sz = 16;
    hf_window_sz = 8;

    % Loop over all of the keypoints.
    for k = 1:size(pos,1)
        x = pos(k,1);
        y = pos(k,2);   

        % Feature window - 17 * 17 pixels
        [Xq,Yq] = meshgrid((0-hf_window_sz-0.5):(0+hf_window_sz+0.5),(0-hf_window_sz-0.5):(0+hf_window_sz+0.5));
        
        % Rotate the grid coordinates.
        M = [cos(Orientation_(k)) -sin(Orientation_(k)); sin(Orientation_(k)) cos(Orientation_(k))];
        X1 = reshape(Xq,[],1);
        Y1 = reshape(Yq,[],1);
        B2 = [X1 Y1];
        A = B2 * M;
        X1 = A(:,1);
        Xq = reshape(X1, window_sz+2, window_sz+2);
        Y1 = A(:,2);
        Yq = reshape(Y1, window_sz+2, window_sz+2);
        
        % get window coordinators according to feature position
        Xq = Xq + x;
        Yq = Yq + y;
        
        % Interpolate the value of window coordinators
        f_window = interp2(L,Xq,Yq);
        f_window(find(isnan(f_window))) = 0;
        
        % Initialize the feature descriptor.
        feat_desc = zeros(1,128);

        fwDx = 0.5*(f_window(2:(end-1), 3:(end)) - f_window(2:(end-1), 1:(end-2)));
        fwDy = 0.5*(f_window(3:(end), 2:(end-1)) - f_window(1:(end-2), 2:(end-1)));
        fwMag = sqrt(fwDx.^2 + fwDy.^2);
        theta = atan2(fwDy, fwDx);
        theta(find(theta == pi)) = -pi;
        % sigma = 0.5 * window_size = 8
        w = fspecial('gaussian', [window_sz window_sz], 8);
        weighted_fwMag = w .* fwMag;
        
        % Histogram the gradient orientation samples weighted by the gradient magnitude and
        % a gaussian with a standard deviation of 1/2 the feature window.  To avoid boundary
        % effects, each sample is accumulated into neighbouring bins weighted by 1-d in
        % all dimensions, where d is the distance from the center of the bin measured in
        % units of bin spacing.
%         for s = 1:size(feat_rot_samples,2)
%             x_sample = feat_rot_samples(1,s);
%             y_sample = feat_rot_samples(2,s);
% 
%             Dx = 0.5*(G(2,3) - G(2,1));
%             Dy = 0.5*(G(3,2) - G(1,2));
%             mag_sample = sqrt( Dx^2 + Dy^2 );
%             grad_sample = atan2( Dy, Dx );
%             if grad_sample == pi
%                 grad_sample = -pi;
%             end      
% 
%             % Compute the weighting for the x and y dimensions.
%             x_wght = max(1 - (abs(feat_rot_grid(1,:) - x_sample)/grid_spacing), 0);
%             y_wght = max(1 - (abs(feat_rot_grid(2,:) - y_sample)/grid_spacing), 0); 
%             pos_wght = reshape(repmat(x_wght.*y_wght,8,1),1,128);
% 
%             % Compute the weighting for the orientation, rotating the gradient to the
%             % main orientation to of the keypoint first, and then computing the difference
%             % in angle to the histogram bin mod pi.
%             diff = mod( grad_sample - Orientation_(k) - orient_angles + pi, 2*pi ) - pi;
%             orient_wght = max(1 - abs(diff)/orient_bin_spacing,0);
%             orient_wght = repmat(orient_wght,1,16);         
% 
%             % Compute the gaussian weighting.
%             g = exp(-((x_sample-x)^2+(y_sample-y)^2)/(2*feat_window^2))/(2*pi*feat_window^2);
% 
%             % Accumulate the histogram bins.
%             feat_desc = feat_desc + pos_wght.*orient_wght*g*mag_sample;
%         end

        % Normalize the feature descriptor to a unit vector to make the descriptor invariant
        % to affine changes in illumination.
        denominator = norm(feat_desc);
        if(denominator ~= 0)
            feat_desc = feat_desc / denominator;
        end
        
        % Threshold the large components in the descriptor to 0.2 and then renormalize
        % to reduce the influence of large gradient magnitudes on the descriptor.
        feat_desc( find(feat_desc > 0.2) ) = 0.2;
        if(denominator ~= 0)
            feat_desc = feat_desc / norm(feat_desc);
        end
        % Store the descriptor.
        desc = [desc; feat_desc];
    end    
    
end
