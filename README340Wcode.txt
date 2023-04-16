This code is a Shiny app that uses the Spotify API and the k-Nearest Neighbors (k-NN) algorithm to recommend similar artists based on the user's input. The app has several input fields, including a text input for the artist's name, and sliders for danceability, energy, and valence.

The app uses the spotifyr package to access the Spotify API and retrieve the audio features of tracks in a specific playlist. The k-NN algorithm is then used to find the most similar tracks based on the selected features.

The app also includes a "Randomize" button, which shuffles the filtered data and displays a randomized table of the tracks that meet the selected criteria. Additionally, the "Clear" button resets all input fields to their default values.

The app calculates a popularity index based on the average popularity of the most similar artists to the user's input. The index is displayed as text output.

To run the app, the required libraries (shiny, spotifyr, tibble, and class) must be installed, and the Spotify API credentials (SPOTIFY_CLIENT_ID and SPOTIFY_CLIENT_SECRET) must be set using Sys.setenv().

To launch the app, call the shinyApp() function, passing in the ui and server objects as arguments.