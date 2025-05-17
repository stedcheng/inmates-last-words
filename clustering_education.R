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
print(table(mydata$Education.level...Highest.Grade.Completed.))

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

### Clustering 2: Educ----------------------------------------------------
#We shall create 3 clusters only

# map the number of years to discrete values
# 0-8 -> Low, 9-11 -> Middle, 12+ -> High
mydata <- mydata %>% rename(Education = Education.level...Highest.Grade.Completed.) %>% 
  mutate(EducCat = ifelse(Education <= 8, 'Low', ifelse(Education <= 11, 'Middle', 'High')))
                            
df_educ <- mydata[,c("EducCat", "Last.Statement")]
df_educ

# Group by education category and count occurrences
educ_counts <- df_educ %>%
  count(EducCat) %>%
  arrange(desc(n))

# Select the top 3 most frequent education category
top_3_educs <- educ_counts$EducCat[1:3]

# Create a function to filter data frames based on race
filter_by_educ <- function(df, educ) {
  df %>%
    filter(EducCat == educ)
}

# Create a list of data frames, each corresponding to one of the top 3 races
data_frames_list <- lapply(top_3_educs, function(educ) {
  filter_by_educ(df_educ, educ)
})

# Name the data frames using the educcat names
names(data_frames_list) <- top_3_educs

data_frames_list
#Extract
df.Low <- data_frames_list$Low
df.Middle <- data_frames_list$Middle
df.High <- data_frames_list$High

### CLUSTERING 2A: LOW ------------------------------------------------

results.low <- cluster_generator(df.Low, "EducCat", "Low")
plot.low <- results.low$plot
dtm.low <- results.low$dtm  

plot.low
#This plot suggests that we do k = 3

# Run LDA -----------------------------------------------------------------

set.seed(1234)
my_lda.low = LDA(dtm.low, k = 3)

word_probs.low = exp(t(my_lda.low@beta))
rownames(word_probs.low) = my_lda.low@terms
View(word_probs.low)

doc_probs.low = exp(my_lda.low@gamma)
mydata.low = cbind(df.Low[rownames(dtm.low),], doc_probs.low)
View(mydata.low)

### CLUSTERING 2B: MIDDLE ------------------------------------------------

results.middle <- cluster_generator(df.Middle, "EducCat", "Middle")
plot.middle <- results.middle$plot
dtm.middle <- results.middle$dtm

plot.middle
#This plot suggests that we do k = 3

# Run LDA -----------------------------------------------------------------

set.seed(1234)
my_lda.middle = LDA(dtm.middle, k = 3)

word_probs.middle = exp(t(my_lda.middle@beta))
rownames(word_probs.middle) = my_lda.middle@terms
View(word_probs.middle)

doc_probs.middle = exp(my_lda.middle@gamma)
mydata.middle = cbind(df.Middle[rownames(dtm.middle),], doc_probs.middle)
View(mydata.middle)

### CLUSTERING 2C: HIGH  ------------------------------------------------

results.high <- cluster_generator(df.High, "EducCat", "High")
plot.high <- results.high$plot
dtm.high <- results.high$dtm 

plot.high
#This plot suggests that we do k = 3

# Run LDA -----------------------------------------------------------------

set.seed(1234)
my_lda.high = LDA(dtm.high, k = 3)

word_probs.high = exp(t(my_lda.high@beta))
rownames(word_probs.high) = my_lda.high@terms
View(word_probs.high)

doc_probs.high = exp(my_lda.high@gamma)
mydata.high = cbind(df.High[rownames(dtm.high),], doc_probs.high)
View(mydata.high)

# Word Cloud

# Do some preliminary graphing
# install.packages(c("wordcloud", "tm"))
library(wordcloud)

# Convert the DTM to a matrix
m.low <- as.matrix(dtm.low)
m.middle <- as.matrix(dtm.middle)
m.high <- as.matrix(dtm.high)

# Extract word frequencies from the DTM
word_freqs.low <- colSums(m.low)
word_freqs.middle <- colSums(m.middle)
word_freqs.high <- colSums(m.high)

# Create the word cloud
# Set up the plot area with a title
plot.new()
title(main = "WordCloud of Common Words in Low Education Demographic")
wordcloud(words = colnames(m.low), freq = word_freqs.low, min.freq = 1,
          max.words=200, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"))

plot.new()
title(main = "WordCloud of Common Words in Middle Education Demographic")
wordcloud(words = colnames(m.middle), freq = word_freqs.middle, min.freq = 1,
          max.words=200, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"))

plot.new()
title(main = "WordCloud of Common Words in High Education Demographic")
wordcloud(words = colnames(m.high), freq = word_freqs.high, min.freq = 1,
          max.words=200, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"))
