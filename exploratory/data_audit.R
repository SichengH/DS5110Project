######################################
## Functions used in the data audit
######################################

is_blank <- function(df){
    types <- sapply(df, class)
    nans <- c()
    blnks <- c()
    for (varname in colnames(df)){
        blnk_vals <- NA
        na_vals <- table(is.na(df[varname]))["TRUE"]        
        if (types[varname] == "character") {
            blnk_vals <- table(sapply(df[varname], nchar) == 0)["TRUE"]
        }
        # Add number of blank values to atomic array
        blnks <- c(blnks, blnk_vals)
        nans <- c(nans, na_vals)
    }
    blank_df <- tibble(variables = colnames(df),
                       num_blanks = blnks,
                       num_nans = nans,
                       field_types = types)
    return(blank_df)
}



