function result = Gaussianfilter(image,sigma,w)
if(~exist('sigma'))
    sigma = 0.5;
end
if(~exist('w'))
    w = 3;
end

  Gaussian = fspecial('Gaussian',[w w],sigma);
  result = filter2(Gaussian,image);
end
