.tr_report_page <- function(hash) {

  httr::GET(
    url = "https://transparencyreport.google.com/transparencyreport/api/v3/httpsreport/ct/certsearch/page",
    query = list(
      p = hash
    )
  ) -> res

  httr::stop_for_status(res)

  res <- httr::content(res, as="text")
  res <- gsub("^\\)]}'\n\n", "", res)

  res <- jsonlite::fromJSON(res)

  cert_log <- list(res[[1]][[1]])

  page_hash <- res[[1]][[4]][2]
  curr_page <- as.numeric(res[[1]][[4]][4])
  total_pages <- as.numeric(res[[1]][[4]][5])

  list(
    cert_log = cert_log,
    page_hash = page_hash,
    curr_page = curr_page,
    total_pages = total_pages
  )

}

#' Query Google's Transparency Repoirt for Certificate Information
#'
#' TODO: "Drill down" for more info
#'
#' @md
#' @param hostname host name (domain)
#' @param include_subdomains,include_expired include subdomains and exipred certs?
#'        Both default to `FALSE`
#' @return list of 2 data frames; one for issuer metadata and one for host/cert metadata
#' @export
tr_report <- function(hostname, include_subdomains=FALSE, include_expired=FALSE) {

  httr::GET(
    url = "https://transparencyreport.google.com/transparencyreport/api/v3/httpsreport/ct/certsearch",
    query = list(
      include_expired = include_expired,
      include_subdomains = include_expired,
      domain = hostname
    ),
    httr::content_type_json(),
    httr::accept_json()
  ) -> res

  httr::stop_for_status(res)

  res <- httr::content(res, as="text")
  res <- gsub("^\\)]}'\n\n", "", res)

  res <- jsonlite::fromJSON(res)

  cert_log <- list(res[[1]][[2]])
  issuer_log <- tibble::as_data_frame(res[[1]][[3]])

  page_hash <- res[[1]][[4]][2]
  curr_page <- as.numeric(res[[1]][[4]][4])
  total_pages <- as.numeric(res[[1]][[4]][5])

  while (curr_page != total_pages) {

    next_pg <- .tr_report_page(page_hash)

    page_hash <- next_pg$page_hash
    curr_page <- next_pg$curr_page
    total_pages <- next_pg$total_pages

    cert_log[length(cert_log)+1] <- next_pg$cert_log

  }

  cert_log <- purrr::map_dfr(cert_log, tibble::as_data_frame)
  cert_log <- purrr::set_names(
    cert_log,
    c("serial_number", "subject", "issuer", "valid_from", "valid_to",
      "ct_hash", "ct_logs_ct", "dns_names", "dns_names_ct", "value")
  )
  cert_log <- cert_log[,1:9]
  cert_log$valid_from <- anytime::anytime(as.numeric(cert_log$valid_from)/1000)
  cert_log$valid_to <- anytime::anytime(as.numeric(cert_log$valid_to)/1000)
  cert_log$ct_logs_ct <- as.numeric(cert_log$ct_logs_ct)
  cert_log$dns_names_ct <- as.numeric(cert_log$dns_names_ct)

  issuer_log <- purrr::set_names(issuer_log, c("id", "ct_hash", "issuer", "issued_ct"))
  issuer_log$issued_ct <- as.numeric(issuer_log$issued_ct)

  list(
    cert_log = cert_log,
    issuer_log = issuer_log
  )

}
