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

# Put each parameter on a new line
string_to_sign <- paste0(ACCESS_ID, "\n", expires)

# Get the "raw" or binary output of the hmac hash
binary_signature <- hmac(SECRET_KEY, string_to_sign, algo = "sha1", raw = TRUE)

# Base64-encode it and then url-encode that
url_safe_signature <- url_encode(base64_enc(binary_signature))

# Set up the API call anatomy
api_host   <- "http://lsapi.seomoz.com/linkscape" # host name and resource for all Mozscape calls
endpoint   <- "url-metrics"
target_url <- "www.seomoz.org"

# Define list of parameters - list can be as long as you need
params <- list(
  Cols = 1+4+8+32 # Uses bit flags to specify which URL metrics to return
)

# Build the URL
req_url <- paste0(api_host, "/",
                  endpoint, "/",
                  url_encode(target_url), "?",
                  paste(names(params), unname(params), sep = "="),
                  "&AccessID=", ACCESS_ID,
                  "&Expires=", expires,
                  "&Signature=", url_safe_signature)


# Perform the call - can all be handled by fromJSON()
r <- fromJSON(req_url)

# Print the result
r
