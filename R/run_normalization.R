#' @include class_RegspliceData.R class_RegspliceResults.R
NULL




#' Calculate normalization factors.
#' 
#' Calculate normalization factors to scale library sizes, using the TMM (trimmed mean of
#' M-values) method implemented in \code{edgeR}.
#' 
#' Normalization factors are used to scale the raw library sizes (total read counts per 
#' sample). We use the TMM (trimmed mean of M-values) normalization method (Robinson and
#' Oshlack, 2010), as implemented in the \code{edgeR} package.
#' 
#' For more details, see the documentation for \code{\link[edgeR]{calcNormFactors}} in
#' the \code{edgeR} package.
#' 
#' This step should be performed after filtering with \code{\link{filter_zeros}} and 
#' \code{\link{filter_low_counts}}. The normalization factors are then used by
#' \code{limma-voom} in the next step (\code{\link{run_voom}}).
#' 
#' The normalization factors are stored in a new column named \code{norm_factors} in the
#' column meta-data (\code{colData} slot) of the \code{\linkS4class{RegspliceData}} 
#' object. The \code{colData} can be accessed with the accessor function 
#' \code{colData()}.
#' 
#' Normalization should be skipped when using exon microarray data. (When using the 
#' \code{\link{regsplice}} wrapper function, normalization can be disabled with the 
#' argument \code{normalize = FALSE}).
#' 
#' Previous step: Filter low-count exon bins with \code{\link{filter_low_counts}}.
#' Next step: Calculate \code{limma-voom} transformation and weights with
#' \code{\link{run_voom}}.
#' 
#' 
#' @param data \code{\linkS4class{RegspliceData}} object, which has already been filtered
#'   with \code{\link{filter_zeros}} and \code{\link{filter_low_counts}}.
#' @param norm_method Normalization method to use. Options are \code{"TMM"}, 
#'   \code{"RLE"}, \code{"upperquartile"}, and \code{"none"}. See documentation for 
#'   \code{\link[edgeR]{calcNormFactors}} in \code{edgeR} package for details. Default is
#'   \code{"TMM"}.
#' 
#' 
#' @return Returns a \code{\linkS4class{RegspliceData}} object. Normalization factors are
#'   stored in the column \code{norm_factors} in the column meta-data (\code{colData}
#'   slot), which can be accessed with the \code{colData()} accessor function.
#' 
#' @seealso \code{\link{filter_low_counts}} \code{\link{run_voom}}
#' 
#' @importFrom edgeR calcNormFactors
#' @importFrom S4Vectors DataFrame SimpleList
#' 
#' @export
#' 
#' @examples 
#' file_counts <- system.file("extdata/vignette_counts.txt", package = "regsplice")
#' data <- read.table(file_counts, header = TRUE, sep = "\t", stringsAsFactors = FALSE)
#' head(data)
#' 
#' counts <- data[, 2:7]
#' tbl_exons <- table(sapply(strsplit(data$exon, ":"), function(s) s[[1]]))
#' gene_IDs <- names(tbl_exons)
#' n_exons <- unname(tbl_exons)
#' condition <- rep(c("untreated", "treated"), each = 3)
#' 
#' Y <- RegspliceData(counts, gene_IDs, n_exons, condition)
#' 
#' Y <- filter_zeros(Y)
#' Y <- filter_low_counts(Y)
#' Y <- run_normalization(Y)
#' 
run_normalization <- function(data, norm_method = "TMM") {
  
  norm_method <- match.arg(norm_method, c("TMM", "RLE", "upperquartile", "none"))
  
  counts <- countsData(data)
  norm_factors <- edgeR::calcNormFactors(counts, method = norm_method)
  
  colData(data)$norm_factors <- norm_factors
  
  data
}



