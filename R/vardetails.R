#' Check vars details
#'
#' @description Check the details of a variable, by searching for it's ID.
#'
#' @param var_id Variable's ID. It can be a single string or a vector.
#'
#' @return A tibble
#'
#' @import httr jsonlite tidyverse
#' @importFrom utils data
#'
#' @export
#'
#' @examples
#' \dontrun{
#' vardetails(var_id = 4049)
#' vardetails(var_id = c(4049,3755,4784))
#' }
#'
vardetails <-
  function(var_id){

    n <- length(var_id)

    if(missing(var_id)){
      stop("Choose an ID for the var_id argument. You can use the datavisR::vars function to search for the id you wish.")
    }else{
      if(n == 1){
        x <- paste0(get_url(info = "var"),
                    "&id=",var_id) |>
          httr::GET(timeout(1000000), config = config(ssl_verifypeer = 0)) |>
          content("text", encoding = "UTF-8") |>
          jsonlite::fromJSON() |>
          tibble::as_tibble() |>
          dplyr::rename(var_id = id,
                 var_name = nome,
                 description = descricao,
                 type = tp_var,
                 decimal_places = nr_casasdecimais,
                 var_id_source = id_fontes
                 ) |>
          dplyr::mutate(var_name = stringr::str_trim(var_name, side = "both"),
                        description = stringr::str_trim(description, side = "both")

          )
      }else{
        x <- var_id |>
          purrr::map_df(.f = function(var_id){
            paste0(get_url(info = "var"),
                   "&id=",var_id) |>
              httr::GET(timeout(1000000), config = config(ssl_verifypeer = 0)) |>
              content("text", encoding = "UTF-8") |>
              jsonlite::fromJSON() |>
              tibble::as_tibble() |>
              dplyr::rename(var_id = id,
                     var_name = nome,
                     description = descricao,
                     type = tp_var,
                     decimal_places = nr_casasdecimais,
                     var_id_source = id_fontes
              ) |>
              dplyr::mutate(var_name = stringr::str_trim(var_name, side = "both"),
                            description = stringr::str_trim(description, side = "both")
              )
          })
      }
    }
    return(x)
  }


