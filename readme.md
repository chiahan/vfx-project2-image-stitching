






## Inverse Warping (Cylindrical Projection)
  讀取所有圖片檔並利用下列公式(inverse warping)將原座標各點像素資訊抓到對應到的圓柱座標上
  

## Harris Corner Detection
  此次偵測特徵點採用Harris方法，步驟如下
1.將圖片資訊轉為灰階值並對其做gaussian，分別對各像素x,y方向做gradient

2.計算每個像素x,y方向的乗積

3.分別對其做gaussian並得到M矩陣

4.下列方程式計算出R，並設定threshold來抓取特徵點


##Feature Description
  

feature matching

RANSAC

image matching

blender

