
# Fundamentals screener
library(tidyverse)
library(jsonlite)
library(alphavantager)
library(TTR)
library(lubridate)
library(finreportr)
library(finstr)
library(XBRL)
library(edgarWebR)
theme_set(theme_classic())

setwd("D:/Analysis/screener")
t <- 5
t_years_ago <- today() %m-% months(t * 12)

##### Download Market Data ####
# Set API key
key <- as.character(read.table("api_key.txt")$V1)
av_api_key(key)

# Get symbols
all_symbols <- stockSymbols()

# Get CIK to ticker map from here: http://rankandfiled.com/#/data/tickers
cik_ticker <- read_delim("D:/Data Sets/Reference Tables/cik_ticker.csv", 
                         "|", escape_double = FALSE, col_types = cols(CIK = col_character(), 
                         IRS = col_character(), SIC = col_character()), 
                         trim_ws = TRUE)

# Get price data
pd <- av_get(symbol = "AAPL", av_fun = "TIME_SERIES_DAILY_ADJUSTED", 
             interval = "daily", interval = "1day", outputsize = "full") 

# Process data
pd <- pd %>% 
      filter(timestamp > t_years_ago) %>%
      mutate(adj_price = close / (close / adjusted_close)) # Split adjusted price


# Plot the last five years
ggplot(pd, aes(x = timestamp, y = adj_price)) +
      geom_line(color = "#3AD900") +
      xlab("") + ylab("") +
      theme(panel.background = element_rect(fill = "#002240"),
            plot.background = element_rect(fill = "#002240"),
            axis.line = element_line(color = "#D0D0D0"),
            axis.text = element_text(color = "#D0D0D0"))

# Cobalt theme: http://www.eclipsecolorthemes.org/?view=theme&id=309

#### Financial Data ####
# Last five years of data from here:
# https://www.sec.gov/dera/data/financial-statement-data-sets.html

# Documentation here:
# https://www.sec.gov/files/aqfs.pdf


datapath <- "D:/Data Sets/SEC"
zipfiles <- grep("zip$", list.files(datapath), value = T)
num <- pre <- sub <- tag <- data.frame()
if (!file.exists("num.RData")) {
      for (z in zipfiles) {
            
            z_dir <- paste0(datapath, "/", z)
            
            # Read each file in the zip archives
            num_tmp <- read_delim(unz(z_dir, "num.txt"), "\t", escape_double = FALSE, trim_ws = TRUE)
            pre_tmp <- read_delim(unz(z_dir, "pre.txt"), "\t", escape_double = FALSE, trim_ws = TRUE)
            sub_tmp <- read_delim(unz(z_dir, "sub.txt"), "\t", escape_double = FALSE, trim_ws = TRUE)
            tag_tmp <- read_delim(unz(z_dir, "tag.txt"), "\t", escape_double = FALSE, trim_ws = TRUE)
            
            # Append to master dataframe
            num <- rbind(num, num_tmp)
            pre <- rbind(pre, pre_tmp)
            sub <- rbind(sub, sub_tmp)
            tag <- rbind(tag, tag_tmp)
      }
      
      saveRDS(num, "num.RData")
      saveRDS(pre, "pre.RData")
      saveRDS(sub, "sub.RData")
      saveRDS(tag, "tag.RData")
      
      rm(num_tmp); rm(pre_tmp); rm(sub_tmp); rm(tag_tmp); gc()
}

library(edgar)
getMasterIndex(c(2013:2018))

report <- getFilings(2017, 0000320193, '10-Q')

# Try finding earnings data from num.txt
eps <- num_tmp %>%
       filter(grepl("^EarningsPerShareDiluted$", tag)) # Only care about EPS for now

# Join the variables we care about from sub
sub <- sub_tmp %>%
      filter(countryba == "US" & countryma == "US", countryinc == "US") %>% # US only for now
      dplyr::select(adsh, cik, name, sic, ein, fye, form, period, fp, instance) %>%
      inner_join(., eps, by = c("adsh" = "adsh"))

head(sub_tmp)
head(tag_tmp)
head(pre_tmp)

unique(tag_tmp$tlabel)
