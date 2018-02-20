#' Retrieve Certificate Transparency Log Server Summaries from the
#' Google Transparency Report Project
#'
#' @md
#' @return data frame (tibble)
#' @references <https://transparencyreport.google.com/https/certificates>
#' @export
tr_log_summary <- function() {

  httr::GET(
    url = "https://transparencyreport.google.com/transparencyreport/api/v3/httpsreport/ct/summary",
    httr::content_type_json(),
    httr::accept_json()
  ) -> res

  httr::stop_for_status(res)

  res <- httr::content(res, as="text")

  res <- gsub("^\\)]}'\n\n\\[\\[\"https.ct.ls\",|\n]\n]", "", res)
  res <- jsonlite::fromJSON(res)
  res <- tibble::as_data_frame(res)
  res <- set_names(res, c("hash", "id", "publisher", "log_url", "tree_size", "ts"))

  res$tree_size <- as.numeric(res$tree_size)
  res$ts <- anytime::anytime(as.numeric(res$ts)/1000)

  res

}