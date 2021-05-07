
library(readxl)
library(ggplot2)
library(tidyverse)
library(dplyr)
library(ggplot2)
library(gganimate)

# remove everything
rm(list = ls())

# Load data
data  <- read_excel("data.xlsx", range = "A1:C101")

# Box plot control vs treatment groups
ggplot(data, aes(y=variable, fill=Group)) +   
  geom_boxplot()+
  labs( y = "", x="", title = "Boxplot of variable X - Control and Treatment groups")+
  theme(plot.title = element_text(color="black", size=30, face="bold"),
        panel.background = element_rect(fill = "grey95", colour = "grey95"),
        axis.text.y = element_text(face="bold", color="black", size = 18),
        axis.text.x = element_blank(),
        legend.title = element_blank(),
        legend.key.size = unit(3, "cm"))

# Summary by group: notice that the average X in Treatment group is 1.47 (22.27 - 20.80) higher than in control group
tapply(data$variable, data$Group, summary)

# T-test: the difference is statistically significant. p-value 0.0003258
t.test(variable ~ Group, data = data)





#########################################################
# Define the number of combinations you want here
comb <- 25000
# create a data frame to include the average differences that we will calculate
df <- data.frame(matrix(ncol = 2, nrow = comb))
colnames(df) <- c("order" ,"diff")

# create the loop for randomization:
for (i in seq(from = 1 , to =comb )  ) {
set.seed(i)                               # setting seed to ensure reproducibility
data$temp <- runif(100, min = 0, max = 1) # creating 100 random numbers 0 to 1
data <- data[order(data$temp),]           # sorting data by the random numbers generated in previous row
data$rank <- rank(data$temp)              # ranking by the random numbers 

# The row below define the treatment group based on the random numbers generated. This is where we guarantee randomization
data$status_rank <-  case_when(data$rank <= 50 ~ "Control_rand", data$rank > 50 ~ "Treated_rand")

# Calculate the new means of the new groups. Need to transpose data.
means <- t(as.data.frame(tapply(data$variable, data$status_rank, mean)))

# Moving the new means to df. Each row is the difference of means
df[i,1] <- i
df[i,2] <- means[1,2] - means[1,1]

rm(means) # Deleting value
data = subset(data, select = -c(temp,rank,status_rank)) # Deleting variables
}
#
#order
df <- df[order(df$diff),]           # sorting data by the random numbers generated in previous row

# Notice there are 12 combination with a difference lower than -1.468
sum(df$diff < -1.468)
head(df$diff)

# Notice there are 5 combination with a difference higher than 1.468
sum(df$diff > 1.468)
tail(df$diff)
#





#########################################################
# data managing before animation
count_data <- df %>%  mutate(x = plyr::round_any(diff, 0.1)) %>%
  group_by(x) %>% mutate(y = seq_along(x))


# create the ggplot 
ggplot(count_data, aes(group = order, x, y)) + # group by index is important
  geom_point(size = 4) +
  labs( y = "", x="", title = "Histogram of differences - Number of dots: 25.000 ")+
  theme(plot.title = element_text(color="darkblue", size=35, face="bold"),
        panel.background = element_rect(fill = "grey95", colour = "grey95"),
        axis.text.x = element_text(face="bold", color="darkblue", size = 16),
        axis.text.y = element_blank(),
        legend.title = element_blank())



# create the ggplot animation

plot <-
  ggplot(count_data, aes(group = order, x, y)) + # group by index is important
  geom_point(size = 4)+
  theme(plot.title = element_text(color="darkblue", size=45, face="bold"),
        panel.background = element_rect(fill = "grey95", colour = "grey95"),
        axis.text.x = element_text(face="bold", color="darkblue", size = 30),
        axis.text.y = element_blank(), 
        legend.title = element_blank())
  
p_anim <- plot + transition_reveal(diff) +  
                labs(title='Percentage of dots: {frame}%')

animate(p_anim,width = 1200 , height = 600)






# create the ggplot object II
#df <- df[order(df$order),]

#g<- ggplot(df,aes(diff))+  
#    labs( y = "", x="", title = "Histogram of differences")+
#    theme(plot.title = element_text(color="darkblue", size=30, face="bold"),
#        panel.background = element_rect(fill = "grey95", colour = "grey95"),
#        axis.text.x = element_text(face="bold", color="darkblue", size = 18),
#        legend.title = element_blank())




#for (i in df$order) {
#  g <- g + geom_histogram(data=df[1:i,])
#}

#anim <- g + transition_layers(keep_layers = FALSE) +  labs(title='Number of dots: {frame}')

#animate(anim,  nframes=comb)














#https://stackoverflow.com/questions/61446108/animated-dot-histogram-built-observation-by-observation-using-gganimate-in-r
#https://www.rdocumentation.org/packages/gganimate/versions/1.0.6/topics/animate
#https://ezgif.com/speed/ezgif-7-7b13cbf7e493.gif

#library(writexl)
#write_xlsx(df,"df3.xlsx")
