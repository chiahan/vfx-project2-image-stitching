function [images, img_count, img_height, img_width] = readImages(img_path)
    images = [];
    
    files = dir([img_path, '/*.jpg']);
    img_count = length(files);
    file1_name = [img_path, '/', files(1).name];
    img = imread(file1_name);
    img_height = size(img,1);
    img_width = size(img,2);
    img_channel = size(img,3);

    images = zeros(img_height, img_width, img_channel, img_count, 'uint8');
     for i = 1:img_count
         filename = [img_path, '/', files(i).name];
         img = imread(filename);
         images(:,:,:,i) = img;
     end
end