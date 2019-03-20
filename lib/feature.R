#############################################################
### Construct features and responses for training images###
#############################################################

### Authors: Chengliang Tang/Tian Zheng
### Project 3

#########Move all the functions out of the loop
###get a single pixel value
get_val=function(img,a,b,d){
  ifelse( (a>0 & a<=nrow(img) & b<=ncol(img) & b>0),
          getarray <- img[a,b,d],
          getarray <- 0)
  return(getarray)
}

###get neighbors of a selected pixel, then substract central
###simply apply this function to the loop
getnbL=function(index, d, imgLR, imgHR){
  c<-(index-1) %/% nrow(imgLR)+1
  r<- index - (c-1)*nrow(imgLR)
  # slow method
  # r <- arrayInd(index, dim(imgLR[,,1]))[1]
  # c <- arrayInd(index, dim(imgLR[,,1]))[2]
  center8 <- get_val(imgLR, r,c,d)
  neighbor8 <- c(get_val(imgLR,r-1,c-1,d), get_val(imgLR,r,c-1,d), get_val(imgLR,r+1,c-1,d),
                     get_val(imgLR,r-1,c,d), get_val(imgLR,r+1,c,d),
                     get_val(imgLR,r-1,c+1,d), get_val(imgLR,r,c+1,d), get_val(imgLR,r+1,c+1,d)) -center8
  neighbor4 <- c(get_val(imgHR,2*r-1,2*c-1,d), get_val(imgHR,2*r,2*c-1,d),
                 get_val(imgHR,2*r-1,2*c,d), get_val(imgHR,2*r,2*c,d)) - center8
  return(list(neighbor8=neighbor8, neighbor4=neighbor4))
}

###get neighbors of one image
getallnb=function(LR_points_total,imgLR, imgHR, n_points=1000){
  feat= array(NA, c(n_points, 8, 3))
  lab= array(NA, c(n_points, 4, 3))
  sample_points <- sample(LR_points_total,n_points, replace = FALSE)
    feat[,,1] <- do.call(rbind,lapply(sample_points[1:n_points],function(x) getnbL(x, d=1, imgLR=imgLR, imgHR=imgHR)$neighbor8))
    feat[,,2] <- do.call(rbind,lapply(sample_points[1:n_points],function(x) getnbL(x, d=1, imgLR=imgLR, imgHR=imgHR)$neighbor8))
    feat[,,3] <- do.call(rbind,lapply(sample_points[1:n_points],function(x) getnbL(x, d=1, imgLR=imgLR, imgHR=imgHR)$neighbor8))
    lab[,,1] <- do.call(rbind,lapply(sample_points[1:n_points],function(x) getnbL(x, d=1, imgLR=imgLR, imgHR=imgHR)$neighbor4))
    lab[,,2] <- do.call(rbind,lapply(sample_points[1:n_points],function(x) getnbL(x, d=1, imgLR=imgLR, imgHR=imgHR)$neighbor4))
    lab[,,3] <- do.call(rbind,lapply(sample_points[1:n_points],function(x) getnbL(x, d=1, imgLR=imgLR, imgHR=imgHR)$neighbor4))
###similar speed by using for loop 
  # for (j in 1:1000){
  #   k = sample_points[j]
  #   feat[j,,1] <- getnbL(k,1,imgLR = imgLR, imgHR=imgHR)$neighbor8
  #   feat[j,,2] <- getnbL(k,2,imgLR = imgLR, imgHR=imgHR)$neighbor8
  #   feat[j,,3] <- getnbL(k,3,imgLR = imgLR, imgHR=imgHR)$neighbor8
  #   lab[j,,1] <- getnbL(k,1,imgLR = imgLR, imgHR=imgHR)$neighbor4
  #   lab[j,,2] <- getnbL(k,1,imgLR = imgLR, imgHR=imgHR)$neighbor4
  #   lab[j,,3] <- getnbL(k,1,imgLR = imgLR, imgHR=imgHR)$neighbor4
  # }
  return(list(feat=feat, lab=lab))
}

# getallnb8=function(sample_points){
#   array1 <- abind(lapply(sample_points[1:1000],function(x) getnbL(x, 1)$neighbor8), along = 0)
#   array2 <- abind(lapply(sample_points[1:1000],function(x) getnbL(x, 2)$neighbor8), along = 0)
#   array3 <- abind(lapply(sample_points[1:1000],function(x) getnbL(x, 3)$neighbor8), along = 0)
#   return(dim(abind(array1,array2,array3, along=3)))
# }
# 
# getallnb4=function(sample_points){
#   array1 <- abind(lapply(sample_points[1:1000],function(x) getnbL(x, 1)$neighbor4), along = 0)
#   array2 <- abind(lapply(sample_points[1:1000],function(x) getnbL(x, 2)$neighbor4), along = 0)
#   array3 <- abind(lapply(sample_points[1:1000],function(x) getnbL(x, 3)$neighbor4), along = 0)
#   return(dim(abind(array1,array2,array3, along=3)))
# }

###########

feature <- function(LR_dir, HR_dir, n_points=1000){

  ### Construct process features for training images (LR/HR pairs)
  
  ### Input: a path for low-resolution images + a path for high-resolution images 
  ###        + number of points sampled from each LR image
  ### Output: an .RData file contains processed features and responses for the images
  
  ### load libraries
  library("EBImage")
  n_files <- length(list.files(LR_dir))
  
  ### store feature and responses
  featMat <- array(NA, c(n_files * n_points, 8, 3))
  labMat <- array(NA, c(n_files * n_points, 4, 3))
  
  
  ### read LR/HR image pairs
  for(i in 1:n_files){
    imgLR <- readImage(paste0(LR_dir,  "img_", sprintf("%04d", i), ".jpg"))@.Data
    imgHR <- readImage(paste0(HR_dir,  "img_", sprintf("%04d", i), ".jpg"))@.Data
    
    ### step 1. sample n_points from imgLR
    LR_points_total <- nrow(imgLR)*ncol(imgLR)
    #temp_matrix <- matrix(c(1:LR_points_total),nrow = LR_pixel_row, byrow=TRUE)
    #excl_margin <- temp_matrix[-c(1,LR_pixel_row), -c(1,LR_pixel_col)]

    
    ### step 2. for each sampled point in imgLR,
    
        ### step 2.1. save (the neighbor 8 pixels - central pixel) in featMat
        ###           tips: padding zeros for boundary points

    
    # savenb8_1 <- abind(lapply(sample_points[1:1000], getnbL, imgLR=imgLR, imgHR=imgHR, d=1),  along = 0)[,1:8]
    # savenb8_2 <- abind(lapply(sample_points[1:1000], getnbL, imgLR=imgLR, imgHR=imgHR, d=2),  along = 0)[,1:8]
    # savenb8_3 <- abind(lapply(sample_points[1:1000], getnbL, imgLR=imgLR, imgHR=imgHR, d=3),  along = 0)[,1:8]
    #     
        ### step 2.2. save the corresponding 4 sub-pixels of imgHR in labMat
    
    # savenb4_1 <- abind(lapply(sample_points[1:1000], getnbL, imgLR=imgLR, imgHR=imgHR, d=1),  along = 0)[,9:12]
    # savenb4_2 <- abind(lapply(sample_points[1:1000], getnbL, imgLR=imgLR, imgHR=imgHR, d=2),  along = 0)[,9:12]
    # savenb4_3 <- abind(lapply(sample_points[1:1000], getnbL, imgLR=imgLR, imgHR=imgHR, d=3),  along = 0)[,9:12]

    ### step 3. repeat above for three channels
  
    featMat[c(((i-1)*n_points+1):(i*n_points)),,] <- getallnb(LR_points_total,imgLR = imgLR, imgHR=imgHR)$feat
    labMat[c(((i-1)*n_points+1):(i*n_points)),,] <- getallnb(LR_points_total,imgLR = imgLR, imgHR=imgHR)$lab

    cat("file", i, "\n")
  
  }
  return(list(feature = featMat, label = labMat))
}
