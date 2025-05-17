# Setup -----------------------------------------------------------------

# Set working directory

# Load libraries 
# If libraries not available, run:
# install.packages(c('tm', 'stopwords', 'stringr', 'topicmodels', 'ggplot2'))
library(tm)
library(stopwords)
library(stringr)
library(topicmodels)
library(tidytext)
library(ggplot2)
library(tidyr)
library(dplyr)

# Load Dataset ------------------------------------------------------------
mydata = read.csv('Texas Inmates 2024.csv',
                  encoding = 'UTF-8')
# Remove blank lines
mydata = mydata[mydata$Last.Statement != "",]
colnames(mydata)

# Determine unique entry for a specific column and get its value
print(table(mydata$Race))

# Define function for cleaning the do clustering-------------------------
cluster_generator <- function(df, demog, specs) {
  clean_text = df$Last.Statement
  clean_text = sapply(clean_text, function(a){
    res = gsub(',', '', a)
    res = gsub('“', '', res)
    res = gsub('”', '', res)
    res = gsub('\n', ' ', res)
    res = gsub(" ?(f|ht)tp(s?)://(.*)[.][a-z]+", '', res)
    res = str_replace_all(res, "[^[:alnum:]]", " ")
    res = tolower(res)
    res = removePunctuation(res)
    res = removeNumbers(res)
    return(res)
  })
  
  dtm = DocumentTermMatrix(VCorpus(VectorSource(
    clean_text
  )), control = list(stopwords = T)) # Stop words are removed!
  dtm = removeSparseTerms(dtm, sparse = 0.99)
  dtm = as.matrix(dtm) # TDM: Term-Document Matrix
  
  if (any(rowSums(dtm) == 0)) {
    warning("Removing rows with zero counts.")
    dtm = dtm[rowSums(dtm) > 0, ]
  }
  
  set.seed(1234)
  fitdf = data.frame()
  for(try_k in seq(2,10, by = 1)){
    print(try_k)
    try_lda = LDA(dtm, k = try_k)
    try_loglik = logLik(try_lda)
    try_perp = perplexity(try_lda)
    fitdf = rbind(fitdf, data.frame(k = try_k, loglik = try_loglik, perp = try_perp))
  }
  
  
  p = ggplot(fitdf, aes(x = k, y = perp))+
    geom_line() + geom_point() + 
    ggtitle(paste0("Perplexity Plot for ", demog, " with Specifications: ", paste(specs, collapse = ", ")))
  
  return(list(dtm = dtm, plot = p))
}

### Clustering 1: Race----------------------------------------------------
#We shall create 3 clusters only
df_race <- mydata[,c("Race", "Last.Statement")]
df_race

# Group by Race and count occurrences
race_counts <- df_race %>%
  count(Race) %>%
  arrange(desc(n))

# Select the top 3 most frequent races
top_3_races <- race_counts$Race[1:3]

# Create a function to filter data frames based on race
filter_by_race <- function(df, race) {
  df %>%
    filter(Race == race)
}

# Create a list of data frames, each corresponding to one of the top 3 races
data_frames_list <- lapply(top_3_races, function(race) {
  filter_by_race(df_race, race)
})

# Name the data frames using the race names
names(data_frames_list) <- top_3_races

data_frames_list
#Extract
df.Black <- data_frames_list$Black
df.White <- data_frames_list$White
df.Hispanic <- data_frames_list$Hispanic

#Here, we will only analyze the Black, White, and Other due to limited data
results.black <- cluster_generator(df.Black, "Race", "Black")
plot.black <- results.black$plot
dtm.black <- results.black$dtm  

plot.black
#This plot suggests that we do k = 3

# Run LDA -----------------------------------------------------------------

set.seed(1234)
my_lda.black = LDA(dtm.black, k = 3)

word_probs.black = exp(t(my_lda.black@beta))
rownames(word_probs.black) = my_lda.black@terms
View(word_probs.black)

doc_probs.black = exp(my_lda.black@gamma)
mydata.black = cbind(df.Black[rownames(dtm.black),], doc_probs.black)
View(mydata.black)

perplexity(my_lda)

### CLUSTERING 1B: WHITE ------------------------------------------------
#Check for white

results.white <- cluster_generator(df.White, "Race", "White")
plot.white <- results.white$plot
dtm.white <- results.white$dtm  

plot.white
#This plot suggests that we do k = 3

# Run LDA -----------------------------------------------------------------

set.seed(1234)
my_lda.white = LDA(dtm.white, k = 3)

word_probs.white = exp(t(my_lda.white@beta))
rownames(word_probs.white) = my_lda.white@terms
View(word_probs.white)

doc_probs.white = exp(my_lda.white@gamma)
mydata.white = cbind(df.White[rownames(dtm.white),], doc_probs.white)
View(mydata.white)

#Check for others

results.his <- cluster_generator(df.Hispanic, "Race", "Hispanic")
plot.his <- results.his$plot
dtm.his <- results.his$dtm  

plot.his
#This plot suggests that we do k = 3

# Run LDA -----------------------------------------------------------------

set.seed(1234)
my_lda.his = LDA(dtm.his, k = 3)

word_probs.his = exp(t(my_lda.his@beta))
rownames(word_probs.his) = my_lda.his@terms
View(word_probs.his)

doc_probs.his = exp(my_lda.his@gamma)
mydata.his = cbind(df.Hispanic[rownames(dtm.his),], doc_probs.his)
View(mydata.his)


# Do some preliminary graphing
install.packages(c("wordcloud", "tm"))
library(wordcloud)

# Convert the DTM to a matrix
m <- as.matrix(dtm.white)

# Extract word frequencies from the DTM
word_freqs <- colSums(m)

# Create the word cloud
# Set up the plot area with a title
plot.new()
title(main = "WordCloud of Common Words in Black Race Demographic")

wordcloud(words = colnames(m), freq = word_freqs, min.freq = 1,
          max.words=200, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"))

