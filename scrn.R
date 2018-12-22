
# Fundamentals screener
library(tidyverse)

setwd("D:/Analysis/screener")

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

