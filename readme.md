






## Inverse Warping (Cylindrical Projection)
  讀取所有圖片檔並利用下列公式(inverse warping)將原座標各點像素資訊抓到對應到的圓柱座標上
  

## Harris Corner Detection
  此次偵測特徵點採用Harris方法，步驟如下
  
1.將圖片資訊轉為灰階值並對其做gaussian，分別對各像素x,y方向做gradient

2.計算每個像素x,y方向的乗積

3.分別對其做gaussian並得到M矩陣

4.下列方程式計算出R，並設定threshold來抓取特徵點


##Feature Description(SIFT Descriptor)
  在特徵點設立一個window，sigma定為1，window size為2*3*(1.5*sigma)+1＝10，代入下列公式計
算出每個像素的m與theta值，將360度分成36等分的bin，並以特徵點的theta值來作為投票，並根據
每個pixel的的w值(由m和gaussian weight所計算出來)進行投票找出每個特徵點的定位方向
  
  接著在每一個特徵點周圍設立一個16x16的window，將所有window轉正並針對window裡的每一個像素
計算出gradient的m和theta，算出來的m值乘以sigma=8的gaussian，再把window切成大小4x4的sub-window
，對sub-window中的theta做投票，裡面分成8等分的bin，權重為m，最後可以得到128維度的特徵點

##Feature Matching
  對兩張圖每個特徵點的128維度向量矩陣做比較，找出相對應的特徵點
  
##RANSAC
  隨機挑選某一對的特徵點，計算出位移量，並算出其他特徵對的位移量與此位移量差，若小於一個設定值
則算在inlier，否則記為outlier

##image matching
  解矩陣Ax=b  
##blender
  對於重複的所有像素各取一半顏色資訊
