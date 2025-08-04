#' Parse Summary File
#'
#' Reads and parses a single summary `.txt` file exported from TargetLynx.
#'
#' @param path A character string representing the file path to the `.txt` file.
#' @return A data frame with parsed data, analyte labels, and source file name.
#' @export
#'
#' @examples
#' example_path <- system.file("extdata", "example_data_lynx_summary.txt", package = "targetRlynx")
#' parse_one_file(example_path)

parse_one_file <- function(path) {
  tryCatch({
    # Read and clean lines
    lines <- base::readLines(path, warn = FALSE)
    lines <- base::iconv(lines, from = "UTF-8", to = "UTF-8", sub = "?")
    lines <- lines[base::nzchar(trimws(lines))]

    if (length(lines) == 0) stop("File is empty or unreadable: ", path)

    # Step 1: Repeated lines as header candidates
    header_candidates <- lines[base::duplicated(lines)]

    # Step 2: Check there are duplicates, double check its expected header for LCMS data including Area, RT, or Name
    if (length(header_candidates) > 0) {
      header_candidates <- lines[
        base::grepl("\\b(RT|Area|Name)\\b", lines) & base::grepl("\t", lines)
      ]
    }

    # Step 3: Fallback if header is not found
    if (length(header_candidates) == 0) {
      stop("No valid header found in file: ", path)
    }

    # Pick best header candidate
    header_line <- header_candidates[1]
    col_names <- base::strsplit(header_line, "\t")[[1]]

    # Locate header positions using fuzzy match
    hdr_pos <- which(base::agrepl(header_line, lines, max.distance = 0.1))
    if (length(hdr_pos) == 0) stop("Could not find fuzzy match for header line in: ", path)

    # Use line above header as analyte label
    analyte_labels <- base::trimws(lines[hdr_pos - 1])
    if (length(analyte_labels) < length(hdr_pos)) analyte_labels <- rep(NA, length(hdr_pos))

    data_blocks <- lapply(seq_along(hdr_pos), function(i) {
      # Start after current header
      start <- hdr_pos[i] + 1
      # End before next header or end of file
      end <- if (i < length(hdr_pos)) hdr_pos[i + 1] - 1 else length(lines)

      block_lines <- lines[start:end]
      block_lines <- block_lines[base::grepl("\t", block_lines)]  # keep tab-separated lines

      return(block_lines)
    })

    all_data_lines <- unlist(data_blocks)
    # Read data safely
    df <- utils::read.table(
      text = all_data_lines,
      sep = "\t",
      header = FALSE,
      col.names = col_names,
      stringsAsFactors = FALSE
    )

    # Label blocks and attach file name
    block_idx <- base::findInterval(base::match(all_data_lines, lines), hdr_pos)
    df$Analyte <- analyte_labels[block_idx]
    df$File <- base::basename(path)

    return(df)

  }, error = function(e) {
    # Return a safe placeholder or diagnostic message
    warning(paste("Error in file:", path, "|", e$message))
    return(NULL)
  })
}

#' Parse one or more TargetLynx `.txt` export files into a parsed data frame
#'
#' This function processes `.txt` files exported by TargetLynx It detects headers
#' using fuzzy matching, extracts analyte names, and reads tabular data blocks.
#' Provide either a directory containing multiple `.txt` files, or a single `.txt` file.
#'
#' If the input ends in `.txt`, it will treat it as a single file. Otherwise, it treats it as a folder.
#'
#' @param path Character. Path to a single `.txt` file or to a folder containing `.txt` files.
#' @return A data frame combining parsed results from one or many files,
#' with analyte labels and source file name. Returns `NULL` if nothing is successfully parsed.
#' @examples
#' # Example with local files (not portable):
#' \dontrun{
#' processRlynx("~/Downloads/")              # multiple files
#' processRlynx("~/Downloads/sample.txt")    # single file
#' }
#'
#' # Example with internal package data:
#' example_path <- system.file("extdata", "example_data_lynx_summary.txt", package = "targetRlynx")
#' parsed <- processRlynx(example_path)
#'
#' @export
processRlynx <- function(path) {
  # Check existence
  if (!file.exists(path)) {
    stop("Path does not exist: ", path)
  }

  # Decide mode based on suffix
  is_file <- base::grepl("\\.txt$", path, ignore.case = TRUE)

  # Gather file list
  files <- if (is_file) {
    path
  } else if (base::dir.exists(path)) {
    base::list.files(path, pattern = "\\.txt$", full.names = TRUE)
  } else {
    stop("Provided path is neither a .txt file nor a valid directory: ", path)
  }

  if (length(files) == 0) {
    stop("No .txt files found at path: ", path)
  }

  # Parse each file safely
  parsed_list <- lapply(files, parse_one_file)
  parsed_list <- parsed_list[!vapply(parsed_list, is.null, logical(1))]  # remove failures

  if (length(parsed_list) == 0) {
    warning("No files parsed successfully. Check formats or header issues.")
    return(NULL)
  }

  dplyr::bind_rows(parsed_list)
}


