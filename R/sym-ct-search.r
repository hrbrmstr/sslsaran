#' Search Certificate Transparency Logs via Symatec CryptoReport
#'
#' @md
#' @param query domain, host, URL, organization name or serial number
#' @return data frame or `NULL` (if no results)
#' @note This performs a live search and the Symantec server can take up to or
#'       longer than 30s to return.
#' @references <https://cryptoreport.websecurity.symantec.com/checker/views/ctsearch.jsp>
sym_ct_search <- function(query) {

  httr::GET(
    url = "https://cryptoreport.websecurity.symantec.com/chainTester/webservice/ctsearch/search",
    query = list(
      keyword = query
    ),
    httr::timeout(30)
  ) -> res

  httr::stop_for_status(res)

  res <- httr::content(res, as="parsed", encoding="UTF-8")

  if (res$status$type == "success") {
    purrr::map_dfr(res$data$certificateDetail, tibble::as_data_frame)
  } else {
    message(res$status$message)
    invisible(NULL)
  }

}
