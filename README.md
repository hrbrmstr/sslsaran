
# sslsaran

Tools to Work with Certificate Transparency Logs

## Description

The ‘IETF’ ‘RFC’ 6962 (<https://tools.ietf.org/html/rfc6962>) describes
an experimental protocol for publicly logging the existence of
‘Transport Layer Security’ (‘TLS’) certificates as they are issued or
observed, in a manner that allows anyone to audit certificate authority
(‘CA’) activity and notice the issuance of suspect certificates as well
as to audit the certificate logs themselves. Functions are provided as a
wrapper around the log server ‘API’.

## What’s Inside The Tin

The following functions are implemented:

  - `get_entries`: Retrieve Entries from Log
  - `get_sth`: Retrieve Latest Signed Tree Head
  - `read_log_list`: Retrieve Certificate Transparency Log List
  - `sslsaran`: Tools to Work with Certificate Transparency Logs

## Installation

``` r
devtools::install_github("hrbrmstr/sslsaran")
```

## Usage

``` r
library(sslsaran)
library(tidyverse)

# current verison
packageVersion("sslsaran")
```

    ## [1] '0.1.0'

``` r
# Get available log servers
ll <- read_log_list()

glimpse(ll$logs)
```

    ## Observations: 26
    ## Variables: 8
    ## $ description         <chr> "Google 'Aviator' log", "Google 'Aviator' log", "Google 'Aviator' log", "Google 'Aviato...
    ## $ key                 <chr> "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE1/TMabLkDpCjiupacAlP7xNi0I1JYP8bQFAHDG1xhtolSY1l4Q...
    ## $ url                 <chr> "ct.googleapis.com/aviator/", "ct.googleapis.com/aviator/", "ct.googleapis.com/aviator/...
    ## $ maximum_merge_delay <int> 86400, 86400, 86400, 86400, 86400, 86400, 86400, 86400, 86400, 86400, 86400, 86400, 864...
    ## $ operated_by         <list> [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 2, 3, 4, 5, 6, 6, 7, 8, 9, 9]
    ## $ final_sth           <list> [46466472, 1.480512e+12, "LcGcZRsm+LGYmrlyC5LXhV1T6OD8iH5dNlb0sEJl9bA=", "BAMASDBGAiEA...
    ## $ dns_api_endpoint    <chr> "aviator.ct.googleapis.com", "aviator.ct.googleapis.com", "aviator.ct.googleapis.com", ...
    ## $ disqualified_at     <int> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 1460678400, 1464566...

``` r
glimpse(ll$operators)
```

    ## Observations: 10
    ## Variables: 2
    ## $ name <chr> "Google", "Cloudflare", "DigiCert", "Certly", "Izenpe", "WoSign", "Venafi", "CNNIC", "StartCom", "Como...
    ## $ id   <int> 0, 1, 2, 3, 4, 5, 6, 7, 8, 9

``` r
# How many certs? (we'll use a different list for this since Chrome is picky)
# NOTE: This usually takes a bit of time to run as some CT servers are slow 
moar_logs <- read_log_list("https://www.gstatic.com/ct/log_list/all_logs_list.json")

pull(moar_logs$logs, url) %>% 
  map(get_sth) %>% 
  map_dbl("tree_size") %>% 
  sum(na.rm=TRUE) %>% 
  scales::comma()
```

    ## [1] "1,126,849,970"

``` r
# Pick one from the google list
ctl <- ll$logs$url[2]

# Get picked latest signed tree head
sth <- get_sth(ctl)

# Get the last 30 entries
x <- get_entries(ctl, sth$tree_size-30, sth$tree_size-1)

# Take a look
glimpse(x)
```

    ## Observations: 30
    ## Variables: 6
    ## $ version          <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ## $ merkle_leaf_type <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ## $ timestamp        <list> [<00, 00, 01, 58, af, cd, 9c, 3e>, <00, 00, 01, 58, af, ce, 4d, 56>, <00, 00, 01, 58, af,...
    ## $ log_entry_type   <dbl> 0, 256, 0, 256, 0, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 2...
    ## $ certificate      <list> [<30, 82, 05, 08, 30, 82, 03, f0, a0, 03, 02, 01, 02, 02, 12, 03, 9a, cc, a0, c5, 32, 3a,...
    ## $ extra_data       <chr> "AAfqAASWMIIEkjCCA3qgAwIBAgIQCgFBQgAAAVOFc2oLheynCDANBgkqhkiG9w0BAQsFADA/MSQwIgYDVQQKExtEa...

``` r
map_chr(x$certificate, ~.x$issuer %||% NA) %>% 
  discard(is.na)
```

    ## [1] "CN=Let's Encrypt Authority X3,O=Let's Encrypt,C=US"           
    ## [2] "CN=Let's Encrypt Authority X3,O=Let's Encrypt,C=US"           
    ## [3] "CN=Let's Encrypt Authority X3,O=Let's Encrypt,C=US"           
    ## [4] "CN=TERENA SSL CA 3,O=TERENA,L=Amsterdam,ST=Noord-Holland,C=NL"
    ## [5] "CN=thawte SSL CA - G2,O=thawte\\, Inc.,C=US"

``` r
map_chr(x$certificate, ~.x$subject %||% NA) %>% 
  discard(is.na)
```

    ## [1] "CN=news.switchlife.jp"                                                                          
    ## [2] "CN=isbase.me"                                                                                   
    ## [3] "CN=isbase.me"                                                                                   
    ## [4] "CN=debian4.irsig.cnr.it,OU=IRSIG,O=Consiglio Nazionale delle Ricerche,L=Roma,ST=Roma,C=IT"      
    ## [5] "CN=da.gatwickairport.com,OU=IT Division,O=Gatwick Airport Limited,L=Gatwick,ST=West Sussex,C=GB"

``` r
map(x$certificate, ~.x$alt_names %||% NA) %>% 
  discard(~is.na(.x[1]))
```

    ## [[1]]
    ## [1] "news.switchlife.jp"
    ## 
    ## [[2]]
    ## [1] "api.isbase.me" "ip.isbase.me"  "isbase.me"     "st.isbase.me"  "t.isbase.me"   "www.isbase.me"
    ## 
    ## [[3]]
    ## [1] "api.isbase.me" "b.isbase.me"   "ip.isbase.me"  "isbase.me"     "st.isbase.me"  "www.isbase.me"
    ## 
    ## [[4]]
    ## [1] "debian4.irsig.cnr.it" "oc.irsig.cnr.it"     
    ## 
    ## [[5]]
    ## [1] "da.gatwickairport.com"
