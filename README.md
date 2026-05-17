# From Dictionaries to LLMs: Text Analysis in R

Talk for **R-Ladies Rome**, May 2026.
[Dariia Mykhailyshyna](https://sites.google.com/view/dariia-mykhailyshyna/) - Kyiv School of Economics.

[**View the slides**](https://dariia-m.github.io/r-ladies-rome-text-analysis/text_analysis_r_ladies_rome.html)

## What's in the talk

A 45-minute walkthrough of a full text-analysis pipeline in R, on a dataset of pro-Russian disinformation claims tracked by [EUvsDisinfo](https://www.kaggle.com/datasets/corrieaar/disinformation-articles).

**Part 1 - the tidytext pipeline**

- Tokenization with `tidytext::unnest_tokens`
- Stopword removal (standard + custom)
- Word frequencies, wordclouds, bar plots
- Dictionary-based sentiment analysis with AFINN, Bing, NRC
- Sentiment over time
- Topic modeling with LDA
- Bigrams and word networks

**Part 2 - LLMs with the `mall` package**

- Local LLMs via Ollama (no API costs)
- `llm_sentiment`, `llm_classify`, `llm_extract`, `llm_summarize`, `llm_verify`, `llm_translate`, `llm_custom`
- When to reach for a dictionary vs. an LLM

## Reproducing the slides

```r
install.packages(c(
  "tidyverse", "tidytext", "stopwords",
  "wordcloud", "wordcloud2", "topicmodels",
  "igraph", "ggraph", "textdata",
  "mall", "ollamar"
))
```

Then install [Ollama](https://ollama.com/download) and pull the model:

```r
ollamar::pull("llama3.2")
```

Render:

```bash
quarto render text_analysis_r_ladies_rome.qmd
```

## Files

| File | Purpose |
|:--|:--|
| `text_analysis_r_ladies_rome.qmd` | Source slides |
| `text_analysis_r_ladies_rome.html` | Rendered deck |
| `kse-theme.scss`, `logo_primary_color.png` | [KSE Quarto template](https://github.com/dariia-m/kse-presentation-templates) |
| `data.csv` | EUvsDisinfo claims, Jan 2015 - Jan 2020 ([source](https://www.kaggle.com/datasets/corrieaar/disinformation-articles)) |
| `smoketest.R` | Standalone script that runs every R chunk - useful for debugging |

## Workshops for Ukraine

If you find this useful, consider [Workshops for Ukraine](https://sites.google.com/view/dariia-mykhailyshyna/main/r-workshops-for-ukraine) - a charity R workshop series whose registration fees support Ukrainian causes.

## Contact

dmykhailyshyna@kse.org.ua
