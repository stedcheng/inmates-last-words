# Setup -----------------------------------------------------------------

# Set working directory
# setwd("G:/My Drive/My Documents/class/PSYC 80.18i/exercises/PSYC80.18i-Exercise04-TextClustering")

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


# Load Dataset ------------------------------------------------------------

# Replace filename as needed
mydata = read.csv('Texas Inmates 2024.csv',
                  encoding = 'UTF-8')


# View first few rows of data
head(mydata)

# # Remove blank lines
# mydata = mydata[which(mydata$TEXT != ''),]

# Change to appropriate column name, 
# e.g., mydata$text or mydata$Text
clean_text = na.omit(mydata$Last.Statement)

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

names(clean_text) = NULL
head(clean_text)


# Convert to tdm

dtm = DocumentTermMatrix(VCorpus(VectorSource(
  clean_text
)), control = list(stopwords = T)) # Stop words are removed!
inspect(dtm)
dtm = removeSparseTerms(dtm, sparse = 0.99)
dtm = (as.matrix(dtm)) # TDM: Term-Document Matrix



# Create word frequency matrix

wordfreqs = data.frame(
  words = colnames(dtm),
  freqs = as.numeric(colSums(dtm))
)

# View result
View(wordfreqs) # What do we notice?


View(dtm)
raw.sum=apply(dtm,1,FUN=sum) #sum by raw each raw of the table
dtm=dtm[raw.sum!=0,]


# Run LDA -----------------------------------------------------------------

set.seed(1234)
my_lda = LDA(dtm, k, method = "Gibbs")

word_probs = exp(t(my_lda@beta))
rownames(word_probs) = my_lda@terms
View(word_probs)

doc_probs = exp(my_lda@gamma)
View(doc_probs)

mydata = cbind(mydata[!is.na(mydata$Last.Statement),], doc_probs)
View(mydata)

logLik(my_lda)
perplexity(my_lda)


# Try many ----------------------------------------------------------------

set.seed(1234)
fitdf = data.frame()
for(try_k in seq(2,10, by = 1)){
  print(try_k)
  try_lda = LDA(dtm, k = try_k)
  try_loglik = logLik(try_lda)
  try_perp = perplexity(try_lda)
  fitdf = rbind(fitdf, data.frame(k = try_k, loglik = try_loglik, perp = try_perp))
}

p = ggplot(fitdf, aes(x = k, y = loglik))+
  geom_line() + geom_point()
p

