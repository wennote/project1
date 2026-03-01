library(shiny)
library(quantmod)
library(TTR)
library(ggplot2)
library(dplyr)
library(lubridate)
library(DT)

# UI
ui <- fluidPage(

  titlePanel("S&P 500 Golden Cross Detector"),

  sidebarLayout(

    sidebarPanel(

      selectInput("start_year", "Start Year:",
                  choices = 1950:year(Sys.Date()),
                  selected = 2015),

      selectInput("start_month", "Start Month:",
                  choices = 1:12,
                  selected = 1),

      selectInput("end_year", "End Year:",
                  choices = 1950:year(Sys.Date()),
                  selected = year(Sys.Date())),

      selectInput("end_month", "End Month:",
                  choices = 1:12,
                  selected = month(Sys.Date())),

      actionButton("update", "Update")

    ),

    mainPanel(

      plotOutput("sp500Plot", height = "500px"),

      h3("Golden Cross Dates"),

      DTOutput("goldenCrossTable")

    )
  )
)

# Server
server <- function(input, output) {

  data <- eventReactive(input$update, {

    start_date <- as.Date(sprintf("%04d-%02d-01",
                                  as.numeric(input$start_year),
                                  as.numeric(input$start_month)))

    end_date <- as.Date(sprintf("%04d-%02d-01",
                                as.numeric(input$end_year),
                                as.numeric(input$end_month))) +
                months(1) - days(1)

    # Download S&P 500 data
    sp500_xts <- getSymbols("^GSPC",
                            from = start_date,
                            to = end_date,
                            auto.assign = FALSE)

    # FIX DATE FORMAT HERE
    df <- data.frame(
      Date = as.Date(index(sp500_xts)),
      Close = as.numeric(Cl(sp500_xts))
    )

    # Calculate moving averages
    df$MA50 <- SMA(df$Close, 50)
    df$MA200 <- SMA(df$Close, 200)

    # Remove NA rows
    df <- df %>% filter(!is.na(MA50) & !is.na(MA200))

    # Correct Golden Cross detection
    df$GoldenCross <- dplyr::lag(df$MA50) <= dplyr::lag(df$MA200) &
                      df$MA50 > df$MA200

    df$GoldenCross[is.na(df$GoldenCross)] <- FALSE

    return(df)
  })

  # Plot
  output$sp500Plot <- renderPlot({

    df <- data()

    golden <- df %>% filter(GoldenCross == TRUE)

    ggplot(df, aes(x = Date)) +

      geom_line(aes(y = Close), color = "black") +

      geom_line(aes(y = MA50), color = "blue", linewidth = 1) +

      geom_line(aes(y = MA200), color = "red", linewidth = 1) +

      geom_point(data = golden,
                 aes(y = Close),
                 color = "green",
                 size = 3) +

      labs(
        title = "S&P 500 Golden Cross Detector",
        x = "Date",
        y = "Price"
      ) +

      theme_minimal()

  })

  # Table with FIXED DATE FORMAT
  output$goldenCrossTable <- renderDT({

    df <- data()

    golden <- df %>%
      filter(GoldenCross == TRUE) %>%
      select(Date, Close, MA50, MA200)

    # Force yyyy-mm-dd format
    golden$Date <- format(as.Date(golden$Date), "%Y-%m-%d")

    datatable(
      golden,
      options = list(pageLength = 10),
      rownames = FALSE
    )

  })

}

# Run app
shinyApp(ui = ui, server = server)
