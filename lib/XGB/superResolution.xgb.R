########################
### Super-resolution ###
########################

### Author: Chengliang Tang
### Project 3

########
pixeldim <- function(imgLR,d){
  rr = nrow(imgLR)
  cc = ncol(imgLR)
  #add two row
  imgLR1 <- abind(array(0,c(1,ncol(imgLR),3)), imgLR, array(0,c(1,ncol(imgLR),3)),  along = 1)
  #add two col
  imgLR2 <- abind(array(0,c(nrow(imgLR1),1,3)), imgLR1, array(0,c(nrow(imgLR1),1,3)),  along = 2)
  
  central <- as.numeric(imgLR2[2:(rr+1), 2:(cc+1),d])
  
  p11 <- as.numeric(imgLR2[1:rr, 1:cc,d]) - central
  p21 <- as.numeric(imgLR2[2:(rr+1), 1:cc,d]) - central
  p31 <- as.numeric(imgLR2[3:(rr+2), 1:cc,d]) - central
  p12 <- as.numeric(imgLR2[1:rr, 2:(cc+1),d]) - central
  p32 <- as.numeric(imgLR2[3:(rr+2), 2:(cc+1),d]) - central
  p13 <- as.numeric(imgLR2[1:rr, 3:(cc+2),d]) - central
  p23 <- as.numeric(imgLR2[2:(rr+1), 3:(cc+2),d]) - central
  p33 <- as.numeric(imgLR2[3:(rr+2), 3:(cc+2),d]) - central
  pexelmattemp <- cbind(p11,p21,p31,p12,p32,p13,p23,p33)
  return(pexelmattemp)
}
########


superResolution <- function(LR_dir, HR_dir, modelList){
  
  
  ### Construct high-resolution images from low-resolution images with trained predictor
  
  ### Input: a path for low-resolution images + a path for high-resolution images 
  ###        + a list for predictors
  
  ### load libraries
  library("EBImage")
  n_files <- length(list.files(LR_dir))
  Total_MSE <- c()
  Total_PSNR <- c()
  ### read LR/HR image pairs
  for(i in 1:n_files){
    imgLR <- readImage(paste0(LR_dir,  "img", "_", sprintf("%04d", i), ".jpg"))@.Data
    pathHR <- paste0(HR_dir,  "img", "_", sprintf("%04d", i), ".jpg")
    totalpixel <- nrow(imgLR) * ncol(imgLR)
    featMat <- array(NA, c(totalpixel, 8, 3))
    
    ### step 1. for each pixel and each channel in imgLR:
    ###           save (the neighbor 8 pixels - central pixel) in featMat
    ###           tips: padding zeros for boundary points
    
    featMat[,,1] <- pixeldim(imgLR,1)
    featMat[,,2] <- pixeldim(imgLR,2)
    featMat[,,3] <- pixeldim(imgLR,3)
    
    ### step 2. apply the modelList over featMat
    predvalue <- test_xgboost(modelList, featMat)
    predMat <- array(predvalue, dim = c(totalpixel,4,3))
    Highimgmat <- array(NA, c(nrow(imgLR)*2, ncol(imgLR)*2, 3))
    
    predMat[,,1] <- predMat[c(1:nrow(predMat)),,1] + as.numeric(imgLR[,,1])
    predMat[,,2] <- predMat[c(1:nrow(predMat)),,2] + as.numeric(imgLR[,,2])
    predMat[,,3] <- predMat[c(1:nrow(predMat)),,3] + as.numeric(imgLR[,,3])
    
    ### step 3. recover high-resolution from predMat and save in HR_dir
    Highimgmat[seq(1, 2*nrow(imgLR), 2), seq(1, 2*ncol(imgLR), 2), ] <- predMat[,1,]
    Highimgmat[seq(2, 2*nrow(imgLR), 2), seq(1, 2*ncol(imgLR), 2), ] <- predMat[,2,]
    Highimgmat[seq(1, 2*nrow(imgLR), 2), seq(2, 2*ncol(imgLR), 2), ] <- predMat[,3,]
    Highimgmat[seq(2, 2*nrow(imgLR), 2), seq(2, 2*ncol(imgLR), 2), ] <- predMat[,4,]
    
    True_HR_Image_Data <- imageData(readImage(paste0("../../data/test_set/HR/",  "img", "_", sprintf("%04d", i), ".jpg")))
    MSE <- mean((True_HR_Image_Data - Highimgmat)^2)
    Total_MSE <- c(Total_MSE, MSE)
    PSNR <- 20*log10(1) - 10*log10(MSE)
    Total_PSNR <- c(Total_PSNR, PSNR)
    
    HR_Image <- Image(Highimgmat, colormode='Color')
    writeImage(HR_Image,pathHR)
    cat("Image", i)
  }
  print("Mean MSE:")
  print(mean(Total_MSE))
  print("Mean PSNR:")
  print(mean(Total_PSNR))
}