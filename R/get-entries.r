#' Retrieve Entries from Log
#'
#' @param log_server CTL log server host and prefix fragment (do not include
#'        `https://` prefix. If one is present it will be removed).
#' @param start,end 0-based index of first & last entry to retrieve, in decimal.
#' @param ... other parameters passed on to `httr::GET`
#' @references <https://tools.ietf.org/html/rfc6962#section-4.6>
#' @export
#' @examples
#' ll <- read_log_list()
#' ctl <- ll$logs$url[2]
#' sth <- get_sth(ctl)
#' x <- get_entries(ctl, sth$tree_size-30, sth$tree_size-1)
get_entries <- function(log_server, start, end) {

  log_server <- gsub("^https://", "", log_server)

  s_GET(
    url = sprintf("https://%sct/v1/get-entries", log_server),
    query = list(
      start = start,
      end = end
    )
  ) -> res

  res <- res$result

  if (is.null(res)) return(list())

  httr::stop_for_status(res)

  res <- httr::content(res, as="parsed", encoding="UTF-8")

  lapply(res$entries, function(.x) {
    y <- openssl::base64_decode(.x[["leaf_input"]])
    z <- pack::unpack("C C H8 v", y[1:12])
    names(z) <- c("version", "merkle_leaf_type", "timestamp", "log_entry_type")
    if (z[["log_entry_type"]] == 0) {
      z[["certificate"]] <- list(openssl::read_cert(y[16:length(y)]))
    }
    z[["extra_data"]] <- .x[["extra_data"]]
    z[["timestamp"]] <- list(z[["timestamp"]])
    z
  }) -> out

  purrr::map_dfr(out, as_data_frame)

}


#      enum { x509_entry(0), precert_entry(1), (65535) } LogEntryType;
#
#      struct {
#          LogEntryType entry_type;
#          select (entry_type) {
#              case x509_entry: X509ChainEntry;
#              case precert_entry: PrecertChainEntry;
#          } entry;
#      } LogEntry;
#
#      opaque ASN.1Cert<1..2^24-1>;
#
#      struct {
#          ASN.1Cert leaf_certificate;
#          ASN.1Cert certificate_chain<0..2^24-1>;
#      } X509ChainEntry;
#
#      struct {
#          ASN.1Cert pre_certificate;
#          ASN.1Cert precertificate_chain<0..2^24-1>;
#      } PrecertChainEntry;

#   Structure of the Merkle Tree input:
#
#       enum { timestamped_entry(0), (255) }
#         MerkleLeafType;
#
#       struct {
#           uint64 timestamp;
#           LogEntryType entry_type;
#           select(entry_type) {
#               case x509_entry: ASN.1Cert;
#               case precert_entry: PreCert;
#           } signed_entry;
#           CtExtensions extensions;
#       } TimestampedEntry;
#
#       struct {
#           Version version;
#           MerkleLeafType leaf_type;
#           select (leaf_type) {
#               case timestamped_entry: TimestampedEntry;
#           }
#       } MerkleTreeLeaf;
#
#   Here, "version" is the version of the protocol to which the
#   MerkleTreeLeaf corresponds.  This version is v1.
#
#   "leaf_type" is the type of the leaf input.  Currently, only
#   "timestamped_entry" (corresponding to an SCT) is defined.  Future
#   revisions of this protocol version may add new MerkleLeafType types.
#   Section 4 explains how clients should handle unknown leaf types.
#
#   "timestamp" is the timestamp of the corresponding SCT issued for this
#   certificate.
#
#   "signed_entry" is the "signed_entry" of the corresponding SCT.
#
#   "extensions" are "extensions" of the corresponding SCT.
#
#   The leaves of the Merkle Tree are the leaf hashes of the
#   corresponding "MerkleTreeLeaf" structures.