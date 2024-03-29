#########################################################
### Train a classification model with training features ###
#########################################################

### Project 3


train_xgboost <- function(dat_train, label_train, par=NULL){
  
  ### Train a Gradient Boosting Model (GBM) using processed features from training images
  
  ### Input: 
  ###  -  features from LR images 
  ###  -  responses from HR images
  ### Output: a list for trained models
  
  ### load libraries
  library("xgboost")
  
  ### creat model list
  modelList <- list()
  
  ### Train with gradient boosting model
  if(is.null(par)){
    depth <- 7
    
  } else {
    depth <- par$depth
  }
  
  ### the dimension of response arrat is * x 4 x 3, which requires 12 classifiers
  ### this part can be parallelized
  for (i in 1:12){
    ## calculate column and channel
    c1 <- (i-1) %% 4 + 1
    c2 <- (i-c1) %/% 4 + 1
    featMat <- dat_train[, , c2]
    labMat <- label_train[, c1, c2]
    fit_xgboost <- xgboost(data = featMat, label = labMat,
                           max_depth = depth,
                           nthread = 3,
                           eta = 0.5,
                           nrounds = 100, verbose = 0)
    cat(" Tunning parameter i = ", i)
    modelList[[i]] <- list(fit=fit_xgboost)
  }
  
  return(modelList)
}
