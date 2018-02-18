#' Retrieve Latest Signed Tree Head
#'
#' @md
#' @param log_server CTL log server host and prefix fragment (do not include
#'        `https://` prefix. If one is present it will be removed).
#' @param ... other parameters passed on to `httr::GET`
#' @return data frame with five columns:
#' - `log_server` what was passed in with any `https://` prefix stripped
#' - `tree_Size` size of the tree, in entries, in decimal.
#' - `timestamp` timestamp
#' - `sha256_root_hash` Merkle Tree Hash of the tree, in base64.
#' - `tree_head_signature` TreeHeadSignature for the above data (sans `log_server`)
#' @references <https://tools.ietf.org/html/rfc6962#section-4.3>
#' @export
#' @examples
#' ll <- read_log_list()
#' ctl <- ll$logs$url[2]
#' sth <- get_sth(ctl)
#' x <- get_entries(ctl, sth$tree_size-30, sth$tree_size-1)
get_sth <- function(log_server, ...) {

  log_server <- gsub("^https://", "", log_server)

  ctl_url <- sprintf("https://%sct/v1/get-sth", log_server)

  s_GET(
    url = ctl_url,
    httr::timeout(.timeout),
    httr::user_agent(.ua),
    ...
  ) -> res

  res <- res$result

  if (is.null(res)) {

    data.frame(
      ctl_url = log_server,
      tree_size = NA,
      timestamp = NA,
      sha256_root_hash = NA,
      tree_head_signature = NA,
      stringsAsFactors = FALSE
    ) -> out

  } else {

    res <- httr::content(res, as="text", encoding="UTF-8")
    res <- jsonlite::fromJSON(res)

    data.frame(
      ctl_url = log_server,
      tree_size = res$tree_size,
      timestamp = anytime::anytime(res$timestamp/1000),
      sha256_root_hash = res$sha256_root_hash,
      tree_head_signature = res$tree_head_signature,
      stringsAsFactors = FALSE
    ) -> out

  }

  class(out) <- c("tbl_df", "tbl", "data.frame")

  out

}