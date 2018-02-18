#' Tools to Work with Certificate Transparency Logs
#'
#' The 'IETF' 'RFC' 6962 (<https://tools.ietf.org/html/rfc6962>) describes an
#' experimental protocol for publicly logging the existence of 'Transport Layer
#' Security' ('TLS') certificates as they are issued or observed, in a manner
#' that allows anyone to audit certificate authority ('CA') activity and notice
#' the issuance of suspect certificates as well as to audit the certificate logs
#' themselves. Functions are provided as a wrapper around the log server 'API'.
#'
#' @md
#' @name sslsaran
#' @docType package
#' @author Bob Rudis (bob@@rud.is)
#' @importFrom purrr safely map map_chr map_dbl map_dfr
#' @importFrom anytime anytime
#' @importFrom httr GET HEAD stop_for_status timeout content user_agent
#' @importFrom jsonlite read_json
#' @importFrom pack unpack
#' @importFrom tibble as_data_frame
NULL
