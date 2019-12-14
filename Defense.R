install.packages("tm")
install.packages("rvest")

library("tm")
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



#pattern:
#semicolon or start of line/space/Cap____spaceLLC or Corp or whatever
#pattern <- "(^|;)//w(LLC|Corp|JV|Inc.)"
