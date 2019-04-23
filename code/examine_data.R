# Date: 2019-04-22
# S Ogletree
# Description: Examine GEE output for Greenest Cities

library(tidyverse)
library(ggalt)

df18 <- read.csv("../data/GreenCity_all_20181211.csv", stringsAsFactors = F)
df13 <- read.csv("../data/GreenCity_all13_20181211.csv", stringsAsFactors = F)
city <- read_csv("../data/city_list.csv")

# add consolidated flag
df18 <- df18 %>% left_join(city)
df13 <- df13 %>% left_join(city)
# look at the spread
df18 %>% 
  arrange(desc(ndvi_mean18)) %>% 
  ggplot(aes(fct_inorder(city_st), ndvi_mean18)) + 
  geom_point() + 
  geom_errorbar(aes(ymin = ndvi_mean18 - ndvi_sd18, ymax = ndvi_mean18 + ndvi_sd18)) +
  theme(axis.title.x=element_blank(), 
        axis.text.x=element_blank())

# top 10 greenest in 2018
green10 <- df18 %>% arrange(desc(ndvi_mean18)) %>% slice(1:10) %>% select(-.geo, -system.index)

green10 %>% ggplot(aes(ndvi_mean18, fct_rev(fct_inorder(city_st)))) + geom_point() + geom_errorbarh(aes(xmax = ndvi_mean18 + ndvi_sd18, xmin = ndvi_mean18 - ndvi_sd18, height = .2), color="gray") + theme(axis.text=element_text(size=11))


# top 10 without consolidated city-county
green10_nocon <- df18 %>% filter(Consolidated == "N") %>% arrange(desc(ndvi_mean18)) %>% slice(1:10) %>% select(-.geo, -system.index)

# the 10 least green
brown10 <- df18 %>% arrange(ndvi_mean18) %>% slice(1:10) %>% select(-.geo, -system.index)

# combine 2013 and 2018 to compare
chng13_18 <- df18 %>% left_join((df13 %>% select(city_st, ndvi_mean13, ndvi_sd13))) %>% select(-.geo, -system.index)

# the biggest growth in green
grow10 <- chng13_18 %>% mutate(diff = ndvi_mean18 - ndvi_mean13) %>% arrange(desc(diff)) %>% slice(1:10)

grow10 %>% mutate(city = fct_inorder(city_st)) %>% 
  mutate(city = fct_rev(city)) %>% 
  ggplot(aes(x=ndvi_mean13, xend=ndvi_mean18, y=city)) +
  geom_dumbbell(size_x = 2, size_xend = 2, colour_x = "darkgray", colour_xend = "darkgreen") +
  labs(title="Green Gains", subtitle= "Change from 2013 to 2018", x="NDVI", y="City") + theme(axis.text=element_text(size=11))

# biggest loss
loss10 <- chng13_18 %>% mutate(diff = ndvi_mean18 - ndvi_mean13) %>% arrange(diff) %>% slice(1:10)

loss10 %>% mutate(city = fct_inorder(city_st)) %>% 
  mutate(city = fct_rev(city)) %>% 
  ggplot(aes(x=ndvi_mean13, xend=ndvi_mean18, y=city)) +
  geom_dumbbell(size_x = 2, size_xend = 2, colour_x = "darkgray", colour_xend = "darkgreen") +
  labs(title="Green Losses", subtitle= "Change from 2013 to 2018", x="NDVI", y="City") + theme(axis.text=element_text(size=11))

# write out
write_csv(grow10, "../data/grow10.csv")
write_csv(green10, "../data/green10.csv")
write_csv(green10_nocon, "../data/green10_nocon.csv")
write_csv(brown10, "../data/brown10.csv")
write_csv(loss10, "../data/loss10.csv")
