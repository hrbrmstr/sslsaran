#' Get Certificate Object
#'
#' Uses the [sslmate Cert Spotter API](https://sslmate.com/certspotter/api) to
#' retrieve the certificate object for a given SHA256 hash.
#'
#' @md
#' @param sha256 hex-encoded SHA-256 digest of the (pre-)certificate.
#' @param as determines the return type. `df` returns a data frame, `pem` returns
#'        an X.509 cert in PEM format (`raw`), `der` returns a DER encoded X.509 cert
#'        that is decoded with [openssl::read_cert()].
#' @param sslmate_api_key (optional) See `Note`.
#' @note Unauthenticated access to the API may be subject to rate limits.
#'       Get an API key [here](https://sslmate.com/account/api_credentials?login=1).
#' @export
cs_get_cert <- function(sha256, as=c("df", "pem", "der"),
                        sslmate_api_key=Sys.getenv("SSLMATE_API_KEY")) {

  as <- match.arg(trimws(tolower(as)), c("df", "pem", "der"))

  fmt <- c("df"="", "pem"=".pem", "der"=".der")[as]

  if (sslmate_api_key != "") {
    httr::GET(
      url = sprintf("https://certspotter.com/api/v0/certs/%s%s", sha256, fmt),
      httr::authenticate(user = sslmate_api_key)
    ) -> res
  } else {
    httr::GET(
      url = sprintf("https://certspotter.com/api/v0/certs/%s%s", sha256, fmt)
    ) -> res
  }

  httr::stop_for_status(res)

  if (as == "df") {
    return(
      tibble::as_data_frame(
        httr::content(res, as="parsed", encoding="UTF-8")
      )
    )
  }

  if (as == "pem") return(openssl::read_cert(httr::content(res, as="raw")))

  return(httr::content(res, as="raw"))

}