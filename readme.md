# [vfx 2015 Spring](http://www.csie.ntu.edu.tw/~cyy/courses/vfx/15spring/ "Digital Visual Effects 2011 Spring") @ CSIE.NTU.EDU.TW
## project #2: Image stitching([original link](http://www.csie.ntu.edu.tw/%7Ecyy/courses/vfx/15spring/assignments/proj2/))

## 程式執行方式
使用matlabR2014a和vlfeat-0.9.20(用在統計bin中的票數)撰寫，執行program資料夾中的main.m，參數都在main.m中最上方修改，input的圖片在"images/(name)"資料夾中，output會在"result/"資料夾中名為(name)_panorama.png

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
inverse warping演算法
![](https://cloud.githubusercontent.com/assets/11717755/7517036/432fc122-f505-11e4-9d64-657c76583af6.PNG)

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
先將整張圖用gaussian filter降低對比度<br>
用以下公式得到每個pixel的角度theta和差值m<br>
![](https://cloud.githubusercontent.com/assets/11753996/7479988/dfeb8d4e-f397-11e4-96ca-948f76613b13.png)
<b>part.1得到主要方向<br></b>
以feature為中心設立一個10*10的window，將差值m和一個大小為10*10的gaussian相乘(靠近中心的pixel較重要)，然後根據角度theta將window中加權後的差值m丟入對應的bin中(360度，每10度一個bin，共36個bin)，總合最高的方向即為該feature的主要方向。若第二高票比第一高票的80%還多，則該feature有兩個方向。<br>


<b>part.2算出描述該FEATURE的128維向量<br></b>
1. 在每一個特徵點周圍設立一個16x16的window，將window依據feature的主要方向旋轉，然後在圖上sample(需透過內插算出每個element的值)<br>
2. 算出16*16window中每個pixel的角度theta和差值m，並用gaussian加權(靠近中心的pixel較重要)<br>
3. 把window切成16個大小4x4的sub-window，根據sub-window中的角度theta將加權後的差值m丟入對應的bin(360度，每45度一個bin，共8個bin)。一個sub-window有8個bin的值，共16個sub-window，所以一個feature最後可得到128個值<br>
4. 將128維的feature vector作normalize成單位向量，normalize後若向量中有>0.2的值，則將他變為0.2然後再normalize一次
###四．Feature Matching
  對兩張圖每個特徵點的128維度向量矩陣算歐式距離，找出距離最近的pair
  
###五．RANSAC
  隨機挑選某兩對match的特徵點，計算出位移量，並算出其他match的位移量與此位移量差，若小於一個threshold
則算在inlier match，否則記為outlier，重複做k=293次，紀錄inlier match最多的那次
![](https://cloud.githubusercontent.com/assets/11717755/7517086/8014b84a-f505-11e4-9b89-33ab3d601f69.PNG)

###六．Image Matching
  利用inlier match，match中的feature對應的座標。<br>
  img1的feature座標為(x,y)，img2的feature座標為(x',y')，計算img1要位移(m1,m2)多少才能和img2接起來<br>
  透過least square解出這個位移量
<div style="display;block">
<img src="https://cloud.githubusercontent.com/assets/11717755/7517622/b130a116-f508-11e4-911d-69819e9d3d57.png">
</div>
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
根據不同的圖片去調整參數，有些圖的feature不明顯，threshold越小，得到的feature越多。feature取太少的話圖片最後會接不起來，feature取太多會跑太慢，我們通常一張圖至少取100個feature
![](https://cloud.githubusercontent.com/assets/11717755/7520417/291f0680-f519-11e4-8430-9d2adb4fabd2.png)
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
解決drift問題，圖片就不會逐漸往上或往下偏移
![](https://cloud.githubusercontent.com/assets/11717755/7521656/48a91438-f522-11e4-9705-0c0ad26c4102.png)
![](https://github.com/chiahan/vfx-project2-image-stitching/blob/master/results/grail_panorama_erase_drift.png)
有做blending，圖片邊界變得不明顯
![](https://github.com/chiahan/vfx-project2-image-stitching/blob/master/results/grail_panorama.png)
### 8.容易犯的錯
-沒有用腳架<br>
-圖片對比不明顯的話很難偵測到feature<br>
-照片重疊的部分太少<br>
-用autostitch算焦距的時候要放縮小後的照片，而不是原圖<br>
-warping的座標，記得要以圖片中心當原點<br>
-旋轉sift descriptor的window也要記得以window中心當原點做旋轉<br>
e.g.失敗品
![](https://github.com/chiahan/vfx-project2-image-stitching/blob/master/results/tree_panorama_3_500.png)
