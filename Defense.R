install.packages("R.utils")
install.packages("rvest")

library("R.utils")
library("rvest")

#load the page we would like to mine
url <- "https://www.defense.gov/Newsroom/Contracts/Contract/Article/2028834/"
webpage <- read_html(url)

#Use the CSS selector 'p' to scrape the text
contract_text_html <- html_nodes(webpage, "p")

#convert it to text
contract_text <- html_text(contract_text_html)

#modifying the vector- look for (\r\n)+ and then seperate them into two different elements
#or can use look behind for the newline
#to seperate can use the contract_text <- insert(contract_text, ats = pos, value) from R.utils package

#NEXT STEPS:

#1. get the data frame stuff up and running

#make sure each paragraph has its own element in the vector
second_paragraph_pattern <- "(?<=\\r\\n).{90,}"
second_paragraphs <- regmatches(contract_text, gregexpr(second_paragraph_pattern, contract_text, perl = TRUE))
contract_text <- gsub(second_paragraph_pattern, "", contract_text, perl = TRUE)


#find where those second paragraphs are
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

company_names[lengths(company_names) == 0] <- NA_character_
contract_amounts[lengths(contract_amounts) == 0] <- NA_character_

#put the two lists in a data frame
new_data <- cbind(company_names, contract_amounts)
new_data <- data.frame(new_data)


#We're here now!

#1. Assume you already have the running tally data frame (make a test one), and then go from there and use it to test
#   the merging by, melting, adding up and all that 

#  Having trouble with the merge function... 
#  1) try using an data frame initialized with two NA columns
#  2) make sure everything's filled (no character(0)s)
#     the same types (character, numeric, etc)
#     try making sure both data frames are the same type
#     both data frames are made of vectors not lists (unlist function?)
#     finding a different function
#     can maybe try as.data.frame on line 51

#Is there a better way to do this? Add the new data to the running data frame
#Also, how do you have a data frame that you always have running each time you rerun your code, do you just have to initialize it the first
#time?
running_tally <- data.frame(company_names = NA, total_contract_amount = NA)
new_data <- merge(x=new_data, y=new_data, by = "company_names", all.x=TRUE)
running_tally$total_contract_amount <- running_tally$total_contract_amount + running_tally$contract_amounts
running_tally$contract_amounts <- NULL



if(company_names == df$Company){
  df$TotalContractsValue += contract_amounts
}

