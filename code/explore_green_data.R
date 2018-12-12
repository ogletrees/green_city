# Date: 2018-12-12
# S Ogletree
# Description: Explore the data

library(tidyverse)
library(ggalt)


df18 <- read.csv("../data/GreenCity_all_20181211.csv", stringsAsFactors = F)
df13 <- read.csv("../data/GreenCity_all13_20181211.csv", stringsAsFactors = F)

# the cities in 2018
df18 %>% ggplot(aes(ndvi_mean18)) + geom_histogram()
# the greenest city is...
df18 %>% arrange(desc(ndvi_mean18)) %>% slice(1:10)
df18 %>% arrange(desc(ndvi_mean18)) %>% slice(1:10) %>% 
  ggplot(aes(ndvi_mean18, fct_rev(fct_inorder(city_st)))) + geom_point() +
  labs(title="Greenest Cities in 2018", x="NDVI 2018", y= "City")


# the least green city is...
df18 %>% arrange(ndvi_mean18) %>% slice(1:5)
df18 %>% arrange(ndvi_mean18) %>% slice(1:10) %>% 
  ggplot(aes(ndvi_mean18, fct_rev(fct_inorder(city_st)))) + geom_point() +
  labs(title="Least Green Cities in 2018", x="NDVI 2018", y= "City")

# compared to 5 years before
chng <- df18 %>% left_join((df13 %>% select(city_st, ndvi_mean13, ndvi_sd13)))
head(chng)
chng <- chng %>% mutate(chng_5yr = ndvi_mean18 - ndvi_mean13)
chng %>% ggplot(aes(chng_5yr)) + geom_histogram()

# biggest increase...
chng %>% arrange(desc(chng_5yr)) %>% slice(1:5)
# biggest decrease...
chng %>% arrange(chng_5yr) %>% slice(1:5)

# Top 10 gains ------------------------------------------------------------
Top10gains <- chng %>% arrange(desc(chng_5yr)) %>% slice(1:10)

Top10gains %>% mutate(city = fct_inorder(city_st)) %>% 
  mutate(city = fct_rev(city)) %>% 
  ggplot(aes(x=ndvi_mean13, xend=ndvi_mean18, y=city)) +
  geom_dumbbell(size_x = 2, size_xend = 2, colour_x = "gray", colour_xend = "darkgreen") +
  labs(title="Green Gains", subtitle= "Change from 2013 to 2018", x="NDVI", y="City")

Top10loss <- chng %>% arrange(chng_5yr) %>% slice(1:10)

Top10loss %>% mutate(city = fct_inorder(city_st)) %>% 
  mutate(city = fct_rev(city)) %>% 
  ggplot(aes(x=ndvi_mean13, xend=ndvi_mean18, y=city)) +
  geom_dumbbell(size_x = 2, size_xend = 2, colour_x = "gray", colour_xend = "darkgreen") +
  labs(title="Green Losses", subtitle= "Change from 2013 to 2018", x="NDVI", y="City")

# change in the top 10

top18 <- df18 %>% arrange(desc(ndvi_mean18)) %>% slice(1:10)
top13 <- df13 %>% filter(city_st %in% top18$city_st)
tops <- top18 %>% left_join(top13)

tops %>% mutate(city = fct_inorder(city_st)) %>% 
  mutate(city = fct_rev(city)) %>% 
  ggplot(aes(x=ndvi_mean18, xend=ndvi_mean13, y=city)) +
  geom_dumbbell(size_x = 2, size_xend = 2, colour_x = "darkgreen", colour_xend = "gray") + 
  labs(title="Top Cities in 2018", subtitle= "Change from 2013 to 2018", x="NDVI", y="City")
