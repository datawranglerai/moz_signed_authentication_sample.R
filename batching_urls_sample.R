## Install the necessary packages
list_of_packages <- c("jsonlite", "digest", "urltools", "RCurl")
new_packages <- list_of_packages[!(list_of_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)

## Load libraries
library(jsonlite)
library(digest)
library(urltools)
library(RCurl)

# Get your access id and secret key here: https://moz.com/products/api/keys
ACCESS_ID  <- "YOUR MOZSCAPE ACCESS ID GOES HERE"
SECRET_KEY <- "YOUR MOZSCAPE SECRET KEY GOES HERE"

# Set expires time for several minutes into the future
# An expires time excessively far in the future will not be honoured by the Mozscape API
expires <- as.integer(as.POSIXct(Sys.time() + 300)) 

# Each parameter on a new line
string_to_sign <- paste0(ACCESS_ID, "\n", expires)

# Get the "raw" or binary output of the hmac hash
binary_signature <- hmac(SECRET_KEY, string_to_sign, algo = "sha1", raw = TRUE)

# Base64-encode it and then url-encode that
url_safe_signature <- url_encode(base64_enc(binary_signature))


# Set up the API call anatomy
api_host   <- "http://lsapi.seomoz.com/linkscape" # host name and resource for all Mozscape calls
endpoint   <- "url-metrics"

params <- list(
  Cols = 1 + 4 + 8
)

# Put your URLS into an array and json_encode them
batched_domains <- c('www.moz.com', 'www.apple.com', 'www.pizza.com')
encoded_domains <- toJSON(batched_domains, auto_unbox = TRUE)

# Build the URL
req_url <- paste0(api_host, "/",
                  endpoint, "/", "?",
                  paste(names(params), unname(params), sep = "="),
                  "&AccessID=", ACCESS_ID,
                  "&Expires=", expires,
                  "&Signature=", url_safe_signature)

# Set HTTP header
http_header <- c(Accept = "application/json",
                 "Content-Type"="application/json")

# Use RCurl to send off your request
r <- postForm(req_url, .opts = list(header = hdr, postfields = encoded_domains))

# Print content from response
content <- fromJSON(r)
r