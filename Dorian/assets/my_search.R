library(rtweet)
library(here)
library(dplyr)
library(rehydratoR)
library(igraph)
library(tidytext)
library(tm)
library(tidyr)
library(ggraph)
library(tidycensus)
library(ggplot2)
library(RPostgres)
library(RColorBrewer)
library(DBI)
library(rccmisc)
library(spdep)
library(sf)

# set up twitter API information with your own information for
# app, consumer_key, and consumer_secret
twitter_token <- create_token(
  app = "Cartastrophe Project",  					#replace yourapp with your app name
  consumer_key = "cJKv1sVmhp1JHYOWTI6ROcE4i",  		#replace yourkey with your consumer key
  consumer_secret = "lunw5kQoOU58fnXYcfrZgB4rDf0Oudzs4iwzFJXKwnXLS1Ujqe",  #replace yoursecret with your consumer secret
  access_token = "3910196838-lrjL5ggowACR2oqqVRo5vjurplyGSQoxOIEK0aW",
  access_secret = "K8M2v0Did0dZ7Qzt2lcE4DdgsDLYKVhDpEmmYRXtlLsEt"
)


#getting tweets for tornado in Mississippi accessed Wednesday May 5th 9pm 
#original count is 20297 tweets 
Miss_tornado = search_tweets("tornado OR storm",
                       n=200000, include_rts=FALSE,
                       token=twitter_token, 
                       geocode="32,-90,300mi",
                       retryonratelimit=TRUE) 

# writing results of the original twitter search
write.table(Miss_tornado$status_id,
            here("data","raw","public","Misstornadoids.txt"), 
            append=FALSE, quote=FALSE, row.names = FALSE, col.names = FALSE)

# get tweets without any text filter for the same geographic region as a baseline 
# changing count n of tweets to reflect original filtered count: 20500
Miss_baseline = search_tweets("-tornado AND -storm", 
                         n=20500, include_rts=FALSE, 
                         token=twitter_token,
                         geocode="32,-90,300mi", 
                         retryonratelimit=TRUE)

# write results of the original twitter baseline search
write.table(Miss_baseline$status_id,
            here("data","raw","public","Missbaselineids.txt"), 
            append=FALSE, quote=FALSE, row.names = FALSE, col.names = FALSE)

Misstornadoids = read.delim(here("data","raw","public","Misstornadoids.txt"))
Missbaselineids = read.delim(here("data","raw","public","Missbaselineids.txt"))






# list and count unique place types
count(Miss_tornado, place_type)

# convert GPS coordinates into lat and lng columns
# do not use geo_coords! Lat/Lng will be inverted
tornado = lat_lng(Miss_tornado, coords=c("coords_coords"))
baseline = lat_lng(Miss_baseline, coords=c("coords_coords"))

# select any tweets with lat and lng columns (from GPS) or 
# designated place types of your choosing
tornado = subset(tornado, 
                place_type == 'city'| place_type == 'neighborhood'| 
                  place_type == 'poi' | !is.na(lat))

baseline = subset(baseline,
                  place_type == 'city'| place_type == 'neighborhood'| 
                    place_type == 'poi' | !is.na(lat))

# convert bounding boxes into centroids for lat and lng columns
tornado = lat_lng(tornado,coords=c("bbox_coords"))
baseline = lat_lng(baseline,coords=c("bbox_coords"))

#rechecking count 
count(tornado, place_type)

############# SAVE FILTERED TWEET IDS TO DATA/DERIVED/PUBLIC ############# 

write.table(tornado$status_id,
            here("data","derived","public","tornadoids.txt"), 
            append=FALSE, quote=FALSE, row.names = FALSE, col.names = FALSE)

write.table(baseline$status_id,
            here("data","derived","public","Missbaselineids.txt"), 
            append=FALSE, quote=FALSE, row.names = FALSE, col.names = FALSE)

############# SAVE TWEETs TO DATA/DERIVED/PRIVATE ############# 

saveRDS(tornado, here("data","derived","private","tornado.RDS"))
saveRDS(baseline, here("data","derived","private","baseline.RDS"))


#### Reading in data 

tornado = readRDS(here("data","derived","private","tornado.RDS"))
baseline = readRDS(here("data","derived","private","baseline.RDS"))


#### ANALYSIS ####

# TEMPORAL ANALYSIS 
tornadoTweetsByHour <- ts_data(tornado, by="hours")
ts_plot(tornado, by="hours", color = "darkblue") + 
  xlab("Date") + 
  ylab("Number of Tweets") +
  theme_minimal()


# TEXTUAL ANALYSIS 
tornadoText = tornado %>% select(text) %>% plain_tweets()

tornadoWords = tornadoText %>% unnest_tokens(word, text)

# also add the twitter search terms to the list
stop_words = stop_words %>% 
  add_row(word="t.co",lexicon = "SMART") %>% 
  add_row(word="tornado",lexicon = "Search") %>% 
  add_row(word="storm",lexicon = "Search")

#delete stop words from dorianWords with an anti_join
tornadoWords =  tornadoWords %>% anti_join(stop_words) 

# graph frequencies of words
# top 15 words in descending order by word count 
tornadoWords %>%
  count(word, sort = TRUE) %>%
  top_n(15) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(x = word, y = n)) +
  geom_col(fill = "darkblue") +
  xlab(NULL) +
  coord_flip() +
  labs(x = "Count",
       y = "Unique words",
       title = "Count of unique words found in tweets") + 
  theme_minimal()


# separate words and count frequency of word pair occurrence in tweets
tornadoWordPairs = tornadoText %>% 
  mutate(text = removeWords(tolower(text), stop_words$word)) %>%
  unnest_tokens(paired_words, text, token = "ngrams", n = 2) %>%
  separate(paired_words, c("word1", "word2"),sep=" ") %>%
  count(word1, word2, sort=TRUE)

# graph a word cloud with space indicating association.
# you may change the filter to filter more or less than pairs with 30 instances
tornadoWordPairs %>%
  filter(n >= 12 & !is.na(word1) & !is.na(word2)) %>%
  graph_from_data_frame() %>%
  ggraph(layout = "fr") +
  geom_edge_link(aes(edge_alpha = n, edge_width = n)) +
  geom_node_point(color = "blue", size = 3) +
  geom_node_text(aes(label = name), vjust = 1.8, size = 3) +
  labs(title = "Word Network of Tweets during Mississippi Tornado",
       x = "", y = "") +
  theme_void()


# SPATIAL ANALYSIS 

#first, sign up for a Census API here:
# https://api.census.gov/data/key_signup.html
#replace the key text 'yourkey' with your own key!
counties <- get_estimates("county",
                          product="population",
                          output="wide",
                          geometry=TRUE, keep_geo_vars=TRUE, 
                          key="9fc71c84584d880b22534869446361718f28536e")


# select only the states you want, with FIPS state codes
# look up fips codes here:
# https://en.wikipedia.org/wiki/Federal_Information_Processing_Standard_state_code 
Miss_counties = filter(counties,
                  STATEFP %in% c('28'))

Surround_counties = filter(counties,
                           STATEFP %in% c('01', '05', '12', '13', '22', '28', '40', '47', '48'))

# save counties to Derived/Public folder
saveRDS(Miss_counties, here("data","derived","public","Miss_counties.RDS"))
saveRDS(Surround_counties, here("data","derived","public","Surround_counties.RDS"))


#reading in data
counties = readRDS(here("data","derived","public","Miss_counties.RDS"))

# map results with GGPlot
# note: cut_interval is an equal interval classification function, while 
# cut_number is a quantile / equal count function
# you can change the colors, titles, and transparency of points
ggplot() +
  geom_sf(data=Surround_counties, aes(fill=cut_number(Surround_counties$DENSITY,5)), color="gray70", size = 0.1)+
  scale_fill_brewer(palette="YlGn")+
  guides(fill=guide_legend(title="Population Density"))+
  geom_point(data = tornado, aes(x=lng,y=lat, color = bots), alpha = .2) +
  scale_color_manual(values=c("purple", "blue")) +
  guides(color=guide_legend(title="Bot Presence"))+
  labs(title = "Tweet Locations During Mississppi Tornado")+
  theme_minimal() +
  theme(plot.title=element_text(hjust=0.5),
        axis.title.x=element_blank(),
        axis.title.y=element_blank())



# SPATIAL JOIN TWEETS AND COUNTIES 
tornado_sf = tornado %>%
  st_as_sf(coords = c("lng","lat"), crs=4326) %>%  # make point geometries
  st_transform(4269) %>%  # transform to NAD 1983
  st_join(select(counties,GEOID))  # spatially join counties to each tweet


tornado_by_county = tornado_sf %>%
  st_drop_geometry() %>%   # drop geometry / make simple table
  group_by(GEOID) %>%      # group by county using GEOID
  summarise(tornado = n())  # count # of tweets


Surround_counties = Surround_counties %>%
  left_join(tornado_by_county, by="GEOID") %>% # join count of tweets to counties
  mutate(tornado = replace_na(tornado, 0)) #replace nulls with 0


# Repeat the workflow above for tweets in November
baseline_by_county = baseline %>% 
  st_as_sf(coords = c("lng","lat"), crs=4326) %>%
  st_transform(4269) %>%
  st_join(select(Surround_counties,GEOID)) %>%
  st_drop_geometry() %>%
  group_by(GEOID) %>% 
  summarise(base = n())

Surround_counties = Surround_counties %>%
  left_join(baseline_by_county, by="GEOID") %>%
  mutate(base = replace_na(base,0))

Surround_counties = Surround_counties %>%
  mutate(torrate = tornado / POP * 10000) %>%  # dorrate is tweets per 10,000
  mutate(ntdi = (tornado - base) / (tornado + base)) %>%  # normalized tweet diff
  mutate(ntdi = replace_na(ntdi,0))   # replace NULLs with 0's

# save counties geographic data with derived tweet rates
saveRDS(Surround_counties,here("data","derived","public","Surround_counties.RDS"))


# SPATIAL CLUSTER ANALYSIS

# This code was originally developed by Casey Lilley (2019)
# and edited by Joseph Holler (2021)
# See https://caseylilley.github.io/finalproj.html

thresdist = Surround_counties %>% 
  st_centroid() %>%     # convert polygons to centroid points
  st_coordinates() %>%  # convert to simple x,y coordinates to play with stdep
  dnearneigh(0, 50, longlat = TRUE) %>%  # use geodesic distance of 110km
  include.self()       # include a county in its own neighborhood (for G*)

# three optional steps to view results of nearest neighbors analysis
thresdist # view statistical summary of the nearest neighbors 
plot(Surround_counties, border = 'lightgrey')  # plot counties background
plot(selfdist, coords, add=TRUE, col = 'red') # plot nearest neighbor ties


#Create weight matrix from the neighbor objects
dwm = nb2listw(thresdist, zero.policy = T)

######## Local G* Hotspot Analysis ######## 
#Get Ord G* statistic for hot and cold spots
Surround_counties$locG = as.vector(localG(Surround_counties$torrate, listw = dwm, 
                                 zero.policy = TRUE))

# optional step to check summary statistics of the local G score
summary(Surround_counties$locG)

# classify G scores by significance values typical of Z-scores
# where 1.15 is at the 0.125 confidence level,
# and 1.95 is at the 0.05 confidence level for two tailed z-scores
# based on Getis and Ord (1995) Doi: 10.1111/j.1538-4632.1992.tb00261.x
# alternatively, Bonferroni correction could be applied to adjust these
# significance thresholds
siglevel = c(1.15,1.95)
Surround_counties = Surround_counties %>% 
  mutate(sig = cut(locG, c(min(Surround_counties$locG),
                           siglevel[2]*-1,
                           siglevel[1]*-1,
                           siglevel[1],
                           siglevel[2],
                           max(Surround_counties$locG))))


# Map hot spots and cold spots!
# breaks and colors from http://michaelminn.net/tutorials/r-point-analysis/
# based on 1.96 as the 95% confidence interval for z-scores
ggplot() +
  geom_sf(data=Surround_counties, aes(fill=sig), color="white", lwd=0.1)+
  scale_fill_manual(
    values = c("#0000FF80", "#8080FF80", "#E6E8E8", "#FF808080", "#FF000080"),
    labels = c("low","", "insignificant","","high"),
    aesthetics = "fill") +
  guides(fill=guide_legend(title="Hot Spots"))+
  labs(title = "Clusters of Tornado Twitter Activity")+
  theme_minimal() +
  theme(plot.title=element_text(hjust=0.5),
        axis.title.x=element_blank(),
        axis.title.y=element_blank())

# Mapping NTDI 
ggplot() +
  geom_sf(data=Surround_counties, aes(fill=ntdi), color="white", lwd=0.1)+
  scale_fill_gradient2(low = "#8c510a", mid = "#E6E8E8", high = "#2166ac", 
                       #labels = c("more tornado tweets","less tornado tweets"),
                       aesthetics = "fill") +
  guides(fill=guide_legend(title="NDTI"))+
  labs(title = "Normalized Difference Tweet Index")+
  theme_minimal() +
  theme(plot.title=element_text(hjust=0.5),
        axis.title.x=element_blank(),
        axis.title.y=element_blank())


##### Changes ##### 

# taking out the bots from the data
# can also use 'contains' to search through string with word 'bot'
tornado_nobots <- tornado %>%
  filter(source %in% c("Twitter for iPhone", "Twitter for Android", "Instagram", "Tweetbot for IOS"))

tornado <- tornado %>%
  mutate(bots = ifelse(source %in% c("Twitter for iPhone", "Twitter for Android", "Instagram", "Tweetbot for IOS"), 
                       "not a bot", 
                       "bot"))




