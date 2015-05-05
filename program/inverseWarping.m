function [warped_images] = inverseWarping(images, img_count, img_h, img_w, f)
    warped_images = zeros(img_h, img_w, 3, img_count, 'uint8');
    y0 = img_h/2;
    x0 = img_w/2;
    for y_new = 1:img_h
        for x_new = 1:img_w
            x = f*tan((x_new-x0)/f);
            y = sqrt(x*x+f*f)*(y_new-y0)/f;
            x = x+x0;
            y = y+y0;
            x = round(x);
            y = round(y);
            if(0<x) & (x<=img_w) & (0<y) & (y<=img_h) warped_images(y_new, x_new, :, :) = images(y, x, :, :);
            else warped_images(y_new, x_new, :, :) = 0;
            end
        end
        end
    %figure(1);imshow(images(:,:,:,1));
    %figure(2);imshow(warped_images(:,:,:,1));
end