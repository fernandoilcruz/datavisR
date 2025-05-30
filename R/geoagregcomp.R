#' Geographic Aggregation Composition
#'
#' @description The geographic aggregation composition. Municipalities are the minimum aggregation level available
#'
#' @param ag Character. The aggregation category. There are  three valid options:
#' * "corede": for coredes (the default), a state-specific planning regionalization only applied to Rio Grande do Sul.
#' * "regfunc": for functional regions, a state-specific planning regionalization only applied to Rio Grande do Sul.
#' * "meso": for IBGE's mesoregions.
#' * "micro": for IBGE's microregions.
#' @param geo_id Numeric. The Greographic unit ID
#' @param period Numeric. The year of the aggregation composition. This is needed only because coredes' composition changed over time. Default is 2022.
#'
#' @return data.frame
#'
#' @import checkmate tidyverse
#' @importFrom utils data
#'
#' @export
#'
#' @examples
#' \dontrun{
#' #' #First run geoagreg() to check the aggregation id of interest
#' geoagreg(ag = "meso")
#' #Let's get id=1 (Centro Ocidental Rio-Grandense) and year 2020 as example.
#' #Run:
#' geoagregcomp(ag = "meso", geo_id = 10, period = 2020)
#'
#' #First run geoagreg() to check the aggregation id of interest
#' geoagreg(ag = "meso")
#' #Let's get id=1 (Centro Ocidental Rio-Grandense) and year 2020 as example.
#' #Run:
#' geoagregcomp(ag = "meso", geo_id = 10, period = 2020)
#'}
#'
geoagregcomp <-
  function(ag = "corede",
           geo_id,
           period = 2022){

    #check arguments
    checkmate::assert_character(ag)
    checkmate::assert_numeric(geo_id)
    checkmate::assert_numeric(period)

    #check available arguments
    ags <- c("micro", "meso", "corede", "regfunc","estado")
    if(!ag %in% ags){stop(paste0("Error: the ag argument is only available for "),
                          paste(ags, collapse = ", "))}

    ids <- geoagreg(ag = ag) |> dplyr::select(geo_id) |> dplyr::pull()
    if(is.null(geo_id)){
      stop("Error: id argument must be provided")
    }else{
      if(!geo_id %in% ids){stop(paste0("Error: the id argument for the ", ag," aggregation is only available for "),
                            paste(ids, collapse = ", "), ". Check the geoagreg() function to find the id you want.")}
    }

    periods <- seq(1994,lubridate::year(Sys.Date())-1)
    if(ag == "corede" & (!period %in% periods)){stop(paste0("Error: the period argument for coredes is only available for "),
                                  paste(periods, collapse = ", "))}

    #url
    url <- paste0(
      get_url(info = "composicao_ag"),
      "&ag=",ag,
      "&id=",geo_id,
      "&periodo=",period
      )

    #output
    x <-
      url |>
      httr::GET(timeout(1000000), config = config(ssl_verifypeer = 0)) |>
      content("text", encoding = "UTF-8") |>
      jsonlite::fromJSON() |>
      tibble::as_tibble() |>
      dplyr::rename("geo_id" = "id",
                    "geo_name" = "nome")

    return(x)

  }
