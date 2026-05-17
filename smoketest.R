## Smoke test - run all R logic from the talk to catch errors before render
suppressPackageStartupMessages({
  needed <- c("tidyverse","tidytext","stopwords","wordcloud","wordcloud2",
              "topicmodels","igraph","ggraph","textdata","lubridate","scales")
  missing <- needed[!vapply(needed, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) {
    cat("MISSING PACKAGES:", paste(missing, collapse=", "), "\n")
    quit(status = 1)
  }
  library(tidyverse); library(tidytext); library(stopwords)
  library(wordcloud); library(topicmodels); library(igraph); library(ggraph)
  library(textdata); library(lubridate); library(scales)
})

setwd("C:/Users/Admin/OneDrive/KSE/RLadies Rome workshop/talk")

articles <- read_csv("data.csv", show_col_types = FALSE)
cat("rows:", nrow(articles), "  cols:", ncol(articles), "\n")
cat("has claim_reviewed:", "claim_reviewed" %in% names(articles), "\n")
cat("has claim_published:", "claim_published" %in% names(articles), "\n")
cat("has ...1:", "...1" %in% names(articles), "\n")

articles_unnested <- articles |>
  unnest_tokens(word, claim_reviewed, to_lower = TRUE)
cat("tokens:", nrow(articles_unnested), "\n")

stop_words <- stopwords(language = "en", source = "marimo")
stop_words_df <- tibble(word = stop_words)
articles_cleaned <- articles_unnested |> anti_join(stop_words_df, by = "word")

stop_words_countries <- c(
  stop_words, "europe","russia","eu","russian","united","states",
  "american","usa","syria","ukraine","kyiv","donbass","crimea","belarus",
  "poland","western","us","ukrainian","eastern","west","donbas","moscow",
  "european","germany","georgia","ukrainians","union","belarusian"
)
articles_no_countries <- articles_unnested |>
  anti_join(tibble(word = stop_words_countries), by = "word")

top_words <- articles_cleaned |> count(word, sort = TRUE)
top_words_no_countries <- articles_no_countries |> count(word, sort = TRUE)
cat("top word:", top_words$word[1], top_words$n[1], "\n")

# Sentiment dictionaries
nrc   <- get_sentiments("nrc")
bing  <- get_sentiments("bing")
afinn <- get_sentiments("afinn")
cat("dict sizes - nrc:", nrow(nrc), "bing:", nrow(bing), "afinn:", nrow(afinn), "\n")

articles_sent <- articles_no_countries |>
  left_join(nrc,   by = "word") |> rename(sent_nrc   = sentiment) |>
  left_join(bing,  by = "word") |> rename(sent_bing  = sentiment) |>
  left_join(afinn, by = "word") |> rename(sent_afinn = value)
cat("sent rows:", nrow(articles_sent), "\n")

# date parse
articles_sent2 <- articles_sent |>
  mutate(month = floor_date(as_date(claim_published), "month"))
ts <- articles_sent2 |>
  group_by(month) |>
  summarise(mean_sent = mean(sent_afinn, na.rm = TRUE), .groups = "drop")
cat("ts rows:", nrow(ts), "  NA mean_sent:", sum(is.na(ts$mean_sent)), "\n")

# DTM + LDA (this is slow - try a smaller k)
articles_dtm <- articles_cleaned |>
  count(word, `...1`) |>
  cast_dtm(`...1`, word, n)
cat("dtm dim:", dim(articles_dtm)[1], "x", dim(articles_dtm)[2], "\n")

set.seed(16)
lda_model <- LDA(articles_dtm, k = 2, method = "Gibbs",
                 control = list(seed = 16, iter = 200))
topics <- tidy(lda_model, matrix = "beta")
cat("topics rows:", nrow(topics), "\n")

# bigrams
articles_bigrams <- articles |>
  unnest_tokens(bigram, claim_reviewed, token = "ngrams", n = 2, to_lower = TRUE)
bigrams_separated <- articles_bigrams |>
  separate(bigram, c("word1","word2"), sep = " ")
bigrams_filtered <- bigrams_separated |>
  filter(!word1 %in% stop_words_df$word,
         !word2 %in% stop_words_df$word)
bigram_counts <- bigrams_filtered |> count(word1, word2, sort = TRUE)
cat("bigram counts rows:", nrow(bigram_counts), "\n")

not_words <- bigrams_separated |>
  filter(word1 == "not") |>
  inner_join(afinn, by = c(word2 = "word")) |>
  count(word2, value, sort = TRUE) |>
  mutate(contribution = n * value)
cat("not_words rows:", nrow(not_words), "  net bias:", round(sum(not_words$contribution), 1), "\n")

bigram_graph <- bigram_counts |> filter(n > 20) |> graph_from_data_frame()
cat("bigram graph nodes:", igraph::vcount(bigram_graph), "edges:", igraph::ecount(bigram_graph), "\n")

cat("\nALL OK\n")
