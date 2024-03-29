######################################################
### Fit the regression model with testing data ###
######################################################

### Project 3

test_xgboost <- function(modelList, dat_test){
  
  ### Fit the classfication model with testing data
  
  ### Input: 
  ###  - the fitted classification model list using training data
  ###  - processed features from testing images 
  ### Output: training model specification
  
  ### load libraries
  library("xgboost")
  
  predArr <- array(NA, c(dim(dat_test)[1], 4, 3))
  
  for (i in 1:12){
    fit_train <- modelList[[i]]
    ### calculate column and channel
    c1 <- (i-1) %% 4 + 1
    c2 <- (i-c1) %/% 4 + 1
    featMat <- dat_test[, , c2]
    # print(featMat)
    # print(fit_train$fit)
    ### make predictions
    predArr[, c1, c2] <- predict(fit_train$fit, newdata=featMat)
    # print(predArr[, c1, c2])
  }
  return(as.numeric(predArr))
}