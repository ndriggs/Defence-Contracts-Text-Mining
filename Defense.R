install.packages("R.utils")
install.packages("rvest")

library("R.utils")
library("rvest")

url <- "https://www.defense.gov/Newsroom/Contracts/"
pgsession <- html_session(url)
pgform <- html_form(pgsession)
new_session <- html_session(submit_form(pgsession,pgform)$url)
pgform_new <- html_form(new_session)


#.info-number .title

#load the page we would like to mine
url <- "https://www.defense.gov/Newsroom/Contracts/Contract/Article/2028834/"
webpage <- read_html(url)

#Use the CSS selector 'p' to scrape the text
contract_text_html <- html_nodes(webpage, "p")

#convert it to text
contract_text <- html_text(contract_text_html)

#next steps ----
#on github page, use ContentScraper to test CSS path
#use parameters ManyPerPattern, KeyWordFilter, and KeyWordAccuracy

Rcrawler(Website="https://www.defense.gov/Newsroom/Contracts/" ,MaxDepth=1,
         crawlUrlfilter = "/Contracts/")

Rcrawler(Website="https://www.defense.gov/Newsroom/Contracts/", MaxDepth=1, 
         crawlUrlfilter = "/Contracts/", ExtractAsText = TRUE, ExtractCSSPat = c(".title"))


#modifying the vector- look for (\r\n)+ and then seperate them into two different elements
#or can use look behind for the newline
#to seperate can use the contract_text <- insert(contract_text, ats = pos, value) from R.utils package

#make sure each paragraph has its own element in the vector
second_paragraph_pattern <- "(?<=\\r\\n).{90,}"
second_paragraphs <- regmatches(contract_text, gregexpr(second_paragraph_pattern, contract_text, perl = TRUE))
second_paragraphs


contract_text <- insert(contract_text, ats = pos, value) #figure out how to make the pos and value work

#pattern <- "(^|;)//w(LLC|Corp\.|JV|Inc\.|LP|Department of word|Co\.|PC)"


#with look behind and end of word at end
pattern <- "(^|(?<=;\\s)).*(Inc\\.|LLC|Corp\\.|JV|LP|Co\\.|PC)\\>" #also can do the look ahead for a comma

#this one works the best so far
#modifications- 1. still needs to catch companies at very start of line that don't end in corp or the like
#2. catch the 2nd and 3rd mention of a company

#test, I can't get the look behind to work, or look ahead for that matter
pattern <- "(?<=\n).{15}"

#the one that workds the best
#how do I catch Co. LLC,
pattern <- "^.*?(Inc\\.|LLC|Corp\\.|JV|LP|Co|Co\\.|PC)" #what to do if it has the . or not after Co
pattern <- "(?<=;\s).*?(Inc\\.|LLC|Corp\\.|JV|LP|Co|Co\\.|PC)"
pattern <- "(?<=;\\s)+.*?,"
company_names <- regmatches(contract_text, gregexpr(pattern, contract_text, perl = TRUE))
company_names
#if multiple companies listed, reject it?

#now extract the dollar amounts
money_pattern <- "awarded\\san?\\s(?:maximum\\s)?\\$\\K\\d+(?:\\,\\d{3})+" 
contract_amounts <- regmatches(contract_text, gregexpr(money_pattern, contract_text, perl = TRUE))
contract_amounts

#put the two lists in a data frame
new_data <- data.frame(company_names, contract_amounts)#************this doesn't work

#Is there a better way to do this? Add the new data to the running data frame
#Also, how do you have a data frame that you always have running each time you rerun your code, do you just have to initialize it the first
#time?
running_tally <- merge(x=running_tally, y=new_data, all.x=TRUE, by="company_names")
running_tally$total_contract_amount <- running_tally$total_contract_amount + running_tally$contract_amounts
running_tally$contract_amounts <- NULL


if(company_names == df$Company){
  df$TotalContractsValue += contract_amounts
}

