# this script should be plugged into LabKey
# it is an R report from the denormalised to a normalised form

# seanvw@gmail.com

# libraries
library("tidyr")
library("dplyr")
library("stringr")

# take the "raw" data not the derived columns
df1 <- labkey.data[,1:13]
# for inspection
head(df1)
# pivot
dfml <- pivot_longer(df1, cols = 2:13)
# for inspection
print(head(dfml))
# give meaningful names
colnames(dfml)[colnames(dfml) == 'name'] <- 'month'
colnames(dfml)[colnames(dfml) == 'value'] <- 'Anomoly_Celcius'
# add a date column
dfml$Date <- dfml$month
# for inspection
head(dfml)
# add numeric dates
dfml <- dfml %>% mutate(Date = case_when(
      Date == 'jan' ~ paste0(year, '-01-01'),
      Date == 'feb' ~ paste0(year, '-02-01'),
      Date == 'mar' ~ paste0(year, '-03-01'),
      Date == 'apr' ~ paste0(year, '-04-01'),
      Date == 'may' ~ paste0(year, '-05-01'),
      Date == 'jun' ~ paste0(year, '-06-01'),
      Date == 'jul' ~ paste0(year, '-07-01'),
      Date == 'aug' ~ paste0(year, '-08-01'),
      Date == 'sep' ~ paste0(year, '-09-01'),
      Date == 'oct' ~ paste0(year, '-10-01'),
      Date == 'nov' ~ paste0(year, '-11-01'),
      Date == 'dec' ~ paste0(year, '-12-01'),
                           TRUE ~ 'Exception'))

# make a separate column for month number 
dfml$Month_Number <- dfml$Date
dfml <- dfml %>% mutate(Month_Number = str_replace_all(Month_Number, "\\d{4}-", ""))
dfml <- dfml %>% mutate(Month_Number = str_replace_all(Month_Number, "-\\d{2}", ""))
dfml$Month_Number <- as.integer(dfml$Month_Number)

# ${tsvout:tsvfile}
write.table(dfml, file = "tsvfile", sep = "\t", qmethod = "double", col.names=NA)

