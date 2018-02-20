#' List Certificates
#'
#' Uses the [sslmate Cert Spotter API](https://sslmate.com/certspotter/api) to
#' list all CT logged certificates for a given domain.
#'
#' @md
#' @param domain Return certificates for the given domain and all sub-domains.
#'        Also returns matching wildcard certificates. Must be at or below a
#'        registered domain.
#' @param expired Include expired certificates? For `TRUE` you'll need an
#'        [sslmate API key](https://sslmate.com/account/api_credentials?login=1)
#'        passed in to the function or stored in the `SSLMATE_API_KEY` environment
#'        variable. Default: `FALSE`. When false, only the most recent (pre-)certificate
#'        is returned for any given tbsCertificate. Default: `FALSE`.
#' @param duplicate Include duplicate certificates?
#' @param sslmate_api_key (optional). See `expired` and `Note`.
#' @return data frame (tibble) with columns:
#' - `type`: (character) cert or precert
#' - `dns_names`: (list) DNS identifiers, from both the Subject CN and the DNS SANs
#' - `sha256`: (character) The hex-encoded SHA-256 digest of the raw X.509 (pre-)certificate
#' - `pubkey_sha256`: (character) The hex-encoded SHA-256 digest of the Subject Public Key Info
#' - `issuer`: (character) The distinguished name of the certificate's issuer
#' - `not_before`: (character) The not before date, in RFC3339 format (e.g. 2016-06-16T00:00:00-00:00)
#' - `not_after`: (character) The not after date, in RFC3339 format (e.g. 2016-06-16T00:00:00-00:00)
#' - `logs`: (list) A list of Certificate Transparency logs containing this (pre-)certificate
#' - `data`: (character) The raw X.509 (pre-)certificate, encoded in base64
#' @note Unauthenticated access to the API may be subject to rate limits.
#' @export
cs_list_certs <- function(domain, expired=FALSE, duplicate=FALSE,
                          sslmate_api_key=Sys.getenv("SSLMATE_API_KEY")) {

  list(
    domain = domain,
    expired = expired,
    duplicate = duplicate
  ) -> params

  if (sslmate_api_key != "") {
    httr::GET(
      url = "https://certspotter.com/api/v0/certs",
      query = params,
      httr::authenticate(user = sslmate_api_key)
    ) -> res
  } else {
    httr::GET(
      url = "https://certspotter.com/api/v0/certs",
      query = params
    ) -> res
  }

  httr::stop_for_status(res)

  res <- httr::content(res, as="parsed", encoding="UTF-8")

  purrr::map_dfr(res, tibble::as_data_frame)

}