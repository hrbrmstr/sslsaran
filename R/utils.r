#' Parse X.509/X.500 Attribute Strings into a Named List
#'
#' @md
#' @param x X.509 attribute string
#' @param as return type. `list` (named list), `char` (named character vector),
#'        `df` (data frame).
#' @return list, data frame or character vector depending on `as`
#' @export
#' @examples
#' x5_attr <- "CN=Sample Cert, OU=R&D, O=Company Ltd., L=Dublin 4, S=Dublin, C=IE"
#' parse_x509_attributes(x5_attr)
#' parse_x509_attributes(x5_attr, "df")
#' parse_x509_attributes(x5_attr, "char")
parse_x509_attributes <- function(x, as=c("list", "df", "char")) {

  as <- match.arg(trimws(tolower(as)), c("list", "df", "char"))

  x <- trimws(stringi::stri_split_regex(x, "(?<!\\\\),")[[1]])
  x <- stringi::stri_split_fixed(x, "=", 2, simplify=TRUE)
  x <- purrr::set_names(x[,2], trimws(x[,1]))

  if (as == "list") return(as.list(x))
  if (as == "df") return(tibble::as_data_frame(as.list(x)))
  return(x)

}
