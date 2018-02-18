#' Retrieve Certificate Transparency Log List
#'
#' @md
#' @param log_list_url a full URL to a known, good CTL log list. Defaults to a
#'        known good one (at the time of package creation) hosted by Google.
#' @return list
#' @references <https://www.certificate-transparency.org/known-logs>
#' @export
#' @examples
#' ll <- read_log_list()
#' ctl <- ll$logs$url[2]
#' sth <- get_sth(ctl)
#' x <- get_entries(ctl, sth$tree_size-30, sth$tree_size-1)
read_log_list <- function(log_list_url = "https://www.gstatic.com/ct/log_list/log_list.json") {
  res <- jsonlite::read_json(log_list_url)
  res$logs <- purrr::map_dfr(res$logs, tibble::as_data_frame)
  res$operators <- purrr::map_dfr(res$operators, tibble::as_data_frame)
  res
}