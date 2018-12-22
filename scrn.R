
# Fundamentals screener
library(tidyverse)

setwd("D:/Analysis/Screener")

# Last five years of data from here:
# https://www.sec.gov/dera/data/financial-statement-data-sets.html

# Documentation here:
# https://www.sec.gov/files/aqfs.pdf

zipfiles <- grep("zip$", list.files(), value = T)
num <- pre <- sub <- tag <- data.frame()
if (!file.exists("num.RData")) {
      for (z in zipfiles) {
            
            # Read each file in the zip archives
            num_tmp <- read_delim(unz(z, "num.txt"), "\t", escape_double = FALSE, trim_ws = TRUE)
            pre_tmp <- read_delim(unz(z, "pre.txt"), "\t", escape_double = FALSE, trim_ws = TRUE)
            sub_tmp <- read_delim(unz(z, "sub.txt"), "\t", escape_double = FALSE, trim_ws = TRUE)
            tag_tmp <- read_delim(unz(z, "tag.txt"), "\t", escape_double = FALSE, trim_ws = TRUE)
            
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
