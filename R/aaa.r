s_GET <- purrr::safely(httr::GET)
.timeout <- 3
.ua <- "#rstats sslsaran package <github.com/hrbrmstr/sslsaran>"