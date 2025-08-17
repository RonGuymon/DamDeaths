# Dam Death Dashboard for John
# Load libraries----
library(shinydashboard)
library(shiny)
library(flexdashboard) # For gauge
library(shinyjs) # For hiding the sidebar by default
library(tidyverse) # Lots of data manipulation
library(readxl) # To load Excel files
library(plotly) # For interactive plots
library(rhandsontable) # For hands on tables
library(leaflet) # For maps

# Load and prepare data----
df = read_excel('Copy of LHD Fatalities Database 08-13-2025.xlsx') |> 
  mutate(
    hover_text = str_glue("{name}<br>{city}, {state}<br>River: {river_name}<br>Contributor: {Contributer}")
  )
# Session timeout info----
timeoutSeconds <- 60*15
inactivity <- sprintf("function idleTimer() {
var t = setTimeout(logout, %s);
window.onmousemove = resetTimer; // catches mouse movements
window.onmousedown = resetTimer; // catches mouse movements
window.onclick = resetTimer;     // catches mouse clicks
window.onscroll = resetTimer;    // catches scrolling
window.onkeypress = resetTimer;  //catches keyboard actions

function logout() {
Shiny.setInputValue('timeOut', '%ss')
}

function resetTimer() {
clearTimeout(t);
t = setTimeout(logout, %s);  // time is in milliseconds (1000 is 1 second)
}
}
idleTimer();", timeoutSeconds*1000, timeoutSeconds, timeoutSeconds*1000)
# Define UI for application that draws a histogram

# Colors----
themeColors <- data.frame(colorName = c("fireEngineRed", 
                                        "deepKoamaru", "persianGreen", "maximumYellowRed", 
                                        "graniteGray"), 
                          hex = c("#D12229", "#28335C", "#00A499", "#F3C454", "#63666A"), 
                          rgb = c("rgb(209,34,41)", "rgb(40,51,92)", "rgb(0,164,153)", "rgb(243,196,84)", "rgb(99,102,106)"))
# Trademark pictures----
customerTrademarkUrl <- ""
customerHomepageUrl <- ""
ourTrademarkUrl <- "https://media.licdn.com/dms/image/v2/C5603AQEItSdAhGE_4w/profile-displayphoto-shrink_200_200/profile-displayphoto-shrink_200_200/0/1517500884820?e=1758153600&v=beta&t=CvlG1TuZBELxk1-LjRGLz5bAlr7E_glJGh_Ok3Ve-2Q"
ourHomepageUrl <- "https://www.linkedin.com/in/john-guymon-54ab9248/"



ui <- dashboardPage(
  dashboardHeader(title = "John's Dam Deaths"),
  dashboardSidebar(
    div(
    style = "padding: 20px; text-align: center;",
    tags$a(href = ourHomepageUrl,
           target = "_blank", # Opens link in a new tab
           style = "color: inherit; text-decoration: none;", # Inherit color and remove underline
           
           # Circular Profile Image
           img(src = ourTrademarkUrl,
               title = "Contact John",
               height = "80px",
               width = "80px",
               style = "border-radius: 50%; margin-bottom: 10px; border: 2px solid #ecf0f5;"),
           
           # Name or Main Text
           div(style = "font-weight: bold; font-size: 16px;", "John Guymon"),
           
           # Sub-text
           div(style = "font-size: 12px; color: #888;", "Click for more details")
    )
  ),
  
  # A separator to distinguish the header from the menu
  tags$hr(style = "margin: 0; border-color: #d2d6de;"),
    sidebarMenu()
  ),
  dashboardBody(
    fluidRow(
      box(
        title='Map',
        leafletOutput('map')
      )
    ),
    fluidRow(
      box(
        title='Raw Data',
        rHandsontableOutput('rawData')
      )
    )
  )
)


server <- function(input, output, session) { 
  
  # Create table----
  output$rawData <- renderRHandsontable({
    rhandsontable(df |> dplyr::select(-hover_text))
  })
  
  # Create map----
  output$map <- renderLeaflet({ 
    leaflet(
      data = df
    ) |> 
      addTiles() |> 
      addCircles(lat = ~latitude,
                 lng = ~longitude,
                 popup = ~hover_text
                 ) |> 
      clearBounds()
  }) 
  
  }

shinyApp(ui, server)