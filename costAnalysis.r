# Solution the costAnalysis question


#import data
cost_data_cleaned <- read.csv('C:\\Users\\nimna\\Documents\\cost_data_cleaned.csv', 
    sep = '\t', header = FALSE)')

#add column names
colnames(cost_data_cleaned) = c("monthID", "production", "cost_incurred")

#check data
str(cost_data_cleaned)

#visualize data
plot(cost_data_cleaned$production, cost_data_cleaned$cost_incurred)

#regression, separately for the two groups
lm(cost_incurred~production, subset(cost_data_cleaned, production < 8500))

lm(cost_incurred~production, subset(cost_data_cleaned, production >= 8500))

