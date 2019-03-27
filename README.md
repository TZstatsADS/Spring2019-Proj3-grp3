# Project: Can you unscramble a blurry image? 
![image](figs/example.png)

### [Full Project Description](doc/project3_desc.md)

Term: Spring 2019

+ Team ##
+ Team members
	+ Yuting He
	+ Seungwook Han
	+ Shengwei Huang
	+ Mengran Xia
	+ Hongye Jiang

+ Project summary: In this project, we created a classification engine for enhance the resolution of images. 
	
**Contribution statement**: ((doc/a_note_on_contributions.md)) All team members contributed equally in all stages of this project. All team members approve our work presented in this GitHub repository including this contributions statement. 

Seungwook Han
* Brainstormed and researched on deep learning-based models that we can use for the super resolution task
* Tried to implement a deep CNN model for the super resolution task (https://github.com/jiny2001/dcscn-super-resolution/)
* Explored and implemented different options for improving the xgboost model by changing and optimizing the parameters (max_depth, nrounds, booster, etc)
* Researched new datasets that we could use as a validation set to ensure the performance of our improved model

Shengwei Huang
* Constructed the basic XGBoost model (train function, test function, cross validation fucntion)
* Performed the cross validation for all possible parameters: [GBTree booster:max_depth,eta / GBLinear booster:alpha,lambda] (together with Seungwook Han)
* Chose the best pair of tuning parameters which can minimize the mean squared error / maximize the psnr or minimize the training time and superResolution time
* Explored more (50) random images to do the testing so that we can see how our model would perform when recovering other types of images


Following [suggestions](http://nicercode.github.io/blog/2013-04-05-projects/) by [RICH FITZJOHN](http://nicercode.github.io/about/#Team) (@richfitz). This folder is orgarnized as follows.

```
proj/
├── lib/
├── data/
├── doc/
├── figs/
└── output/
```

Please see each subfolder for a README file.
