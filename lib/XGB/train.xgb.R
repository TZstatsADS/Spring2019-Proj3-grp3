
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

  if(!is.null(par[["depth"]])) {
    depth <- par$depth
  }
  else {
    depth <- 5
  }
  if(!is.null(par[["eta"]])) {
    eta <- par$eta
  }
  else {
    eta <- 0.5
  }
  
  ### the dimension of response arrat is * x 4 x 3, which requires 12 classifiers
  ### this part can be parallelized
  for (i in 1:12){
    ## calculate column and channel
    c1 <- (i-1) %% 4 + 1
    c2 <- (i-c1) %/% 4 + 1
    featMat <- dat_train[, , c2]
    labMat <- label_train[, c1, c2]
    cat("Training model with depth: ", depth, "\n")
    cat("Training model with eta: ", eta, "\n")
    fit_xgboost <- xgboost(booster="gblinear", data = featMat, label = labMat,
                           max_depth = depth,
                           eta = eta,
                           nrounds = 10, verbose = 0)
    cat(" Tunning parameter i = ", i)
    modelList[[i]] <- list(fit=fit_xgboost)
  }
  
  return(modelList)
}