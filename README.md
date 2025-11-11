💡 Acknowledgements

Some parts of the code, deployment setup, and bug fixes were completed with help from ChatGPT, especially for:
Resolving API CORS issues
Optimizing image display and popup responsiveness
Configuring GitHub Pages deployment steps

Special thanks to:

Pokémon TCG API
 for providing the dataset
Flutter & Dart teams for the open-source tools
GitHub Pages for free web hosting

🟩 Pokémon Green Cards — Flutter Web App

A responsive Flutter web and mobile app that lists Pokémon cards and allows players to battle two random Pokémon based on their HP.
The app uses data from a Pokémon TCG JSON source and is deployed live via GitHub Pages.

🚀 Live Demo

👉 View the app on GitHub Pages-
https://armaan5628.github.io/pokemon-green-cards-battle/

🧩 Features

🗂️ All Cards View — Displays all Pokémon cards fetched from a JSON API
Each card shows its name and small image.
Tap a card to view the full-size version in a popup (fits all screen sizes).
⚔️ Battle Mode — Randomly selects two Pokémon cards and compares their HP to declare a winner.
Includes a “Play Again” button for repeated matches.

🧠 Data Source — Uses a hosted JSON file to avoid CORS issues.

JSON URL: https://raw.githubusercontent.com/Armaan5628/pokemonapi/refs/heads/main/api.json
💻 Fully Responsive — Works smoothly on both desktop and mobile browsers.
🌈 Modern Flutter UI — Built with Material Design 3 components.

🛠️ Tech Stack
Technology	Purpose
Flutter (3.x)	Framework for building the cross-platform app
Dart	Programming language
HTTP Package	Fetches Pokémon data from API
GitHub Pages	Web hosting platform
JSON API	Data source for Pokémon card information
