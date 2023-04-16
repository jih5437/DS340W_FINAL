library(shiny)
library(spotifyr)
library(tibble)
library(class)
Sys.setenv(SPOTIFY_CLIENT_ID = '68588c6543464d40b3e17ca23e3f178c')
Sys.setenv(SPOTIFY_CLIENT_SECRET = '32956d387caf47b38fbed3b39666d430')
access_token <- get_spotify_access_token()
playlist_tracks <- get_playlist_tracks("6UeSakyzhiEt4NB3UAd6NQ")
playlist_track_ids <- playlist_tracks$track.id
audio_features <- get_track_audio_features(playlist_track_ids)
train_data <- audio_features[, c("danceability", "energy", "valence")]
train_labels <- audio_features$energy
k <- 5
model <- knn(train_data, train_data, train_labels, k)
df3 <- NULL
ui <- fluidPage(
  textInput(inputId = "artist_input", label = "Enter artist name"),
  sliderInput(inputId = "danceability_range", label = "Danceability:",
              min = 0, max = 1, value = c(0.3, 0.8), step = 0.1),
  sliderInput(inputId = "energy_range", label = "Energy:",
              min = 0, max = 1, value = c(0.3, 0.8), step = 0.1),
  sliderInput(inputId = "valence_range", label = "Valence:",
              min = 0, max = 1, value = c(0.3, 0.8), step = 0.1),
  actionButton(inputId = "submit_button", label = "Submit"),
  actionButton(inputId = "clear_button", label = "Clear"),
  actionButton(inputId = "randomize_button", label = "Randomize"),
  textOutput(outputId = "result_table1"),
  dataTableOutput(outputId = "result_table2")
)
server <- function(input, output, session) {
  artist_data <- reactive({
    pull <- get_artist_audio_features(input$artist_input)
    df3 <<- rbind(pull, df3)
    result <- df3
    if (is.data.frame(result)) {
      result
    } else {
      NULL
    }
  })
  filtered_data <- reactive({
    artist_data() %>%
      filter(danceability >= input$danceability_range[1] & danceability <= input$danceability_range[2],
             energy >= input$energy_range[1] & energy <= input$energy_range[2],
             valence >= input$valence_range[1] & valence <= input$valence_range[2])
  })
  similar_artists <- reactive({
    new_data <- filtered_data() %>%
      select(danceability, energy, valence)
    if (nrow(new_data) > 0) {
      knn(train_data, new_data, train_labels, k)
    } else {
      NULL
    }
  })
  observeEvent(input$clear_button, {
    updateTextInput(session, "artist_input", value = "")
    updateSliderInput(session, "danceability_range", value = c(0.3, 0.8))
    updateSliderInput(session, "energy_range", value = c(0.3, 0.8))
    updateSliderInput(session, "valence_range", value = c(0.3, 0.8))
    df3 <<- NULL
  })
  observeEvent(input$randomize_button, {
    if (!is.null(filtered_data())) {
      shuffled_data <- filtered_data()[sample(nrow(filtered_data())),]
      output$result_table2 <- renderDataTable({
        shuffled_data %>%
          select(artist_name, danceability, energy, valence, track_name, external_urls.spotify) %>%
          arrange(artist_name)
      })
    }
  })
  output$result_table1 <- renderText({
    if (!is.null(similar_artists())) {
      data.frame(Artist = similar_artists()) %>%
        filter(Artist != input$artist_input) %>%
        arrange(Artist) %>%
        summarise(avg = mean(as.numeric(Artist), na.rm = TRUE)) %>%
        pull(avg) %>%
        paste("The Popularity Index of this selection is:", .)
    } else {
      NULL
    }
  })
  output$result_table2 <- renderDataTable({
    if (!is.null(filtered_data())) {
      filtered_data() %>%
        select(artist_name, danceability, energy, valence, track_name, external_urls.spotify) %>%
        arrange()
    } else {
      NULL
    }
  })
  
}
shinyApp(ui, server)
