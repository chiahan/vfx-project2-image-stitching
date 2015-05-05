function [X,Y,RT]= harrisDetection(image, sigma, w, threshold, k)

    grayimage = rgb2gray(image);
    I = gaussianFilter(grayimage,sigma,w);
    [Ix,Iy] = gradient(I);

    Ix2 = Ix.^2;
    Iy2 = Iy.^2;
    Ixy = Ix.*Iy;

    Sx2 = gaussianFilter(Ix2,sigma,w);
    Sy2 = gaussianFilter(Iy2,sigma,w);
    Sxy = gaussianFilter(Ixy,sigma,w);

    R = (Sx2.*Sy2-Sxy.^2)-k*(Sx2+Sy2).^2;

    RT = R>threshold;
    RT = RT & (R>imdilate(R,[1 1 1;1 0 1;1 1 1]));
    
    [Y,X] = find(RT);

end