compiler::enableJIT(0)

if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("AnnotationDbi")
BiocManager::install("hgu133plus2.db")

if (!requireNamespace("dplyr", quietly = TRUE)) {
  install.packages("dplyr")
}

library(dplyr)

library(hgu133plus2.db)
library(AnnotationDbi)

data <- read.csv("/Users/admin/Desktop/common_probe_df.csv")

data$gene.id <- NA_character_  # Adds an empty column to 'data'

# Ensure data$probe.id is indeed a character vector, as expected
data$probe.id <- as.character(data$probe.id)


getFirstGeneSymbol <- function(probe_id) {
  tryCatch({
    query_result <- AnnotationDbi::select(hgu133plus2.db, 
                                          keys = probe_id, 
                                          columns = "SYMBOL", 
                                          keytype = "PROBEID")
    if (nrow(query_result) > 0) {
      return(query_result$SYMBOL[1])  # Return the first gene symbol
    } else {
      return(NA)  # No gene symbol found
    }
  }, error = function(e) {
    return(NA)  # Return NA in case of error
  })
}

data <- data %>%
  rowwise() %>%
  mutate(gene.id = getFirstGeneSymbol(probe.id))

data_clean <- data %>%
  filter(!is.na(gene.id))

write.csv(data_clean, "/Users/admin/Desktop/common_probe_to_geneid.csv", row.names = FALSE, fileEncoding = "UTF-8")
