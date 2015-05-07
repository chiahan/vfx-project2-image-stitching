# [vfx 2015 Spring](http://www.csie.ntu.edu.tw/~cyy/courses/vfx/15spring/ "Digital Visual Effects 2011 Spring") @ CSIE.NTU.EDU.TW
## project #2: Image stitching([original link](http://www.csie.ntu.edu.tw/%7Ecyy/courses/vfx/15spring/assignments/proj2/))

## 程式執行方式
使用matlab2014a撰寫，執行program資料夾中的main.m，參數都在main.m中最上方修改，input的圖片在"images/(name)"資料夾中，output會在"result/"資料夾中名為(name)_panorama.png

##實作內容
1. inverse warping
2. feature detection (harris corner detection)
3. feature description (sift descriptor)
4. feature matching 
5. RANSAC 
6. image matching 
7. blending (by weighting function) & solve drift problem

### ㄧ．Inverse Warping (Cylindrical Projection)
  讀取所有圖片檔並利用下列公式(inverse warping)將原座標各點像素資訊抓到對應到的圓柱座標上
![](https://cloud.githubusercontent.com/assets/11753996/7479938/9666b6e4-f397-11e4-8e81-eb6802f78ce5.png)  
!!!放inverse warping演算法的圖
### 二．Feature Detection
  此次偵測特徵點採用Harris方法，步驟如下
  
1.將圖片資訊轉為灰階值並對其做gaussian，分別對各像素x,y方向做gradient
<div style="display;block">
<img src="https://cloud.githubusercontent.com/assets/11753996/7479958/ae6d9942-f397-11e4-803a-2d2b13e4d830.png">
</div>
2.計算每個像素x,y方向的乗積
<div style="display;block">
<img src="https://cloud.githubusercontent.com/assets/11753996/7479971/bf91ac7c-f397-11e4-8ba5-044e3a2ec64e.png">
</div>
3.分別對其做gaussian並得到M矩陣
<div style="display;block">
<img src="https://cloud.githubusercontent.com/assets/11753996/7479977/c94ada04-f397-11e4-9887-e8316cbedc89.png">
</div>
4.下列方程式計算出R，並設定threshold來抓取特徵點
<div style="display;block">
<img src="https://cloud.githubusercontent.com/assets/11753996/7479983/d3771f7e-f397-11e4-8d31-c6e40ace745b.png">
</div>

###三．Feature Description(SIFT Descriptor)
  在特徵點設立一個window，sigma定為1，window size為2*3*(1.5*sigma)+1＝10，代入下列公式計
算出每個像素的m與theta值，將360度分成36等分的bin，並以特徵點的theta值來作為投票，並根據
每個pixel的的w值(由m和gaussian weight所計算出來)進行投票找出每個特徵點的定位方向
![](https://cloud.githubusercontent.com/assets/11753996/7479988/dfeb8d4e-f397-11e4-96ca-948f76613b13.png)
  
  接著在每一個特徵點周圍設立一個16x16的window，將所有window轉正並針對window裡的每一個像素
計算出gradient的m和theta，算出來的m值乘以sigma=8的gaussian，再把window切成大小4x4的sub-window
，對sub-window中的theta做投票，裡面分成8等分的bin，權重為m，最後可以得到128維度的特徵點

###四．Feature Matching
  對兩張圖每個特徵點的128維度向量矩陣算歐式距離，找出距離最近的pair
  
###五．RANSAC
  隨機挑選某兩對match的特徵點，計算出位移量，並算出其他match的位移量與此位移量差，若小於一個threshold
則算在inlier match，否則記為outlier，重複做k=293次，紀錄inlier match最多的那次
！！！放ransac演算法地圖

###六．Image Matching
  利用inlier match，match中的feature對應的座標。
  img1的feature座標為(x,y)，img2的feature座標為(x',y')，計算img1要位移(m1,m2)多少才能和img2接起來
  透過least square解出這個位移量
  ！！！放矩陣圖
  p.s.我們的code是從右邊往左接
  
###七．Blending
  對於重疊的像素區域各取一半顏色資訊(weighting function（如下圖），讓兩張圖片的接縫處不明顯，並將第一張和最後一張照片的高度差平均分配給所有相片的位移，來解決drift問題
![](https://cloud.githubusercontent.com/assets/11717755/7515751/4d65ec9c-f4fc-11e4-93ca-0d23908be9e3.PNG)

## 結果與討論
原圖
![](https://cloud.githubusercontent.com/assets/11717755/7514220/3cd46060-f4ee-11e4-98d1-4066220b3167.png)
### 1.warp到圓柱後
![](https://cloud.githubusercontent.com/assets/11717755/7515694/d03ce798-f4fb-11e4-8800-88285d61a2dd.png)
### 2.feature detection
根據不同的圖片去調整參數，有些圖的feature不明顯，threshold越小，得到的feature越多。feature取太少的話圖片最後會接不起來，feature取太多會跑太慢，我們通常都取100~300個feature
！！！放圖
### 3.feature descriptor
feature數量可能會增加幾十個
### 4.feature matching
### 5.RANSAC
做完RANSAC把outliers刪掉後，feature大約剩下2/3的量。
### 6.image matching
沒解決drift問題，也沒做blending<br>
drift情況很嚴重
![](https://github.com/chiahan/vfx-project2-image-stitching/blob/master/results/parrington_panorama_drift.png)
圖片交界處色差明顯
![](https://github.com/chiahan/vfx-project2-image-stitching/blob/master/results/grail_panorama_drift.png)
### 7.blending
有解決drift問題，圖片不會逐漸往上或往下偏移
![](https://github.com/chiahan/vfx-project2-image-stitching/blob/master/results/grail_panorama_erase_drift.png)
有做blending，圖片邊界變得不明顯
![](https://github.com/chiahan/vfx-project2-image-stitching/blob/master/results/tree_panorama_3_500.png)
### 8.others
失敗品
沒有用腳架，圖片對比不明顯的話很難偵測到feature
![](https://github.com/chiahan/vfx-project2-image-stitching/blob/master/results/parrington_panorama_drift.png)
