# load data
data("iris")

# load packages
library("caret")

# if seed for reproducible randomness, if desired
# set.seed(998)

# partition rows numbers of data for training as int vector
inTrain <- createDataPartition(iris$Species,p=0.7,list=FALSE)
str(inTrain)

# create train data
# slice data frame per inTrain vector values
training <- iris[inTrain,]

#fit predictive model
model <- train(Species~.,data=training,method='rf')

# create test data set
testing <- iris[-inTrain,]

# Run the model on the test set
predicted <- predict(model,newdata=testing)

# Determine the model accuracy
accuracy <- sum(predicted == testing$Species)/length(predicted)

# Print the model accuracy
print(accuracy)

confusionMatrix(predicted, testing$Species)
