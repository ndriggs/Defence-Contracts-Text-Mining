install.packages("R.utils")
install.packages("rvest")
install.packages("tidyverse")

library("R.utils")
library("rvest")
library("tidyverse")

#create a backup file of our current data, then load the data into our program
file.copy("contract_data.csv", "backup.csv")
all_data <- read.csv("contract_data.csv")

#load the page we would like to mine
url <- "https://www.defense.gov/Newsroom/Contracts/Contract/Article/2028834/"
webpage <- read_html(url)

#Use the CSS selector 'p' to scrape the text
contract_text_html <- html_nodes(webpage, "p")

#convert it to text
contract_text <- html_text(contract_text_html)

#make sure each paragraph has its own seperate spot in the vector
second_paragraph_pattern <- "(?<=\\r\\n).{90,}"
second_paragraphs <- regmatches(contract_text, gregexpr(second_paragraph_pattern, contract_text, perl = TRUE))
contract_text <- gsub(second_paragraph_pattern, "", contract_text, perl = TRUE)

#find where those double paragraphs are
indicies <- which(sapply(second_paragraphs, length) > 0) + 1
second_paragraphs <- second_paragraphs[lengths(second_paragraphs) > 0]
contract_text <- insert(contract_text, ats = indicies, values=second_paragraphs)

#extract company names
pattern <- "^.*?(Inc\\.|LLC|Corp\\.|JV|LP|Co|Co\\.|PC|(?=,))" 
company_names <- regmatches(contract_text, gregexpr(pattern, contract_text, perl = TRUE))
company_names

#now extract the dollar amounts
money_pattern <- "awarded\\san?\\s.*?(?:maximum\\s)?.*?\\$\\K\\d+(?:\\,\\d{3})+" 
contract_amounts <- regmatches(contract_text, gregexpr(money_pattern, contract_text, perl = TRUE))
contract_amounts

#delete rows where there's not data for both
contract_amounts <- as.numeric(gsub(",", "", as.character(contract_amounts)))
contract_amounts[(lengths(company_names) == 0)] <- NA
company_names[is.na(contract_amounts)] <- NULL
company_names <- unlist(company_names)
contract_amounts <- contract_amounts[!is.na(contract_amounts)]

#create a date column
date <- rep(Sys.Date(), times=length(company_names))

#put the newly extracted data all together in a data frame
new_data <- data.frame(date, company_names, contract_amounts)
names(new_data) <- c("Date", "Company Name", "Contract Amount")

#merge the old and new data
all_data <- rbind(all_data, new_data)

write.csv(all_data, "contract_data.csv")

#to compare the culmulative totals between companies
all_data %>% 
  +     group_by(`Company Name`) %>% 
  +     mutate(cumulative_amount = cumsum(`Contract Amount`)) %>% 
  +     ggplot(aes(x = `Company Name`, y = cumulative_amount)) +
  +     geom_point() +
  +     geom_line() 
#  +     facet_wrap(~`Company Name`)
