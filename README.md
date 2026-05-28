# JobHUD Frontend

JobHUD is the Flutter frontend for a job-search and career-guidance experience. This repository is now focused on the web app that can be deployed to GitHub Pages.

## What is included

- Flutter UI for job discovery, saved jobs, tips, culture fit, and profile views
- Web-first build setup for GitHub Pages
- Simple local development and deployment instructions

## Quick start

1. cd jobhud
2. flutter pub get
3. flutter run -d chrome

## GitHub Pages deployment

The project includes a GitHub Actions workflow that builds the web app and publishes it to GitHub Pages automatically.

### Steps

1. Push this repository to GitHub.
2. Open Settings → Pages.
3. Set Source to GitHub Actions.
4. Run the workflow from the Actions tab.

### Build command

flutter build web --release --base-href "/JobHud/"

## Project structure

- jobhud/lib/ — Flutter screens, providers, services, and widgets
- jobhud/web/ — web entry point and metadata
- .github/workflows/ — deployment workflow for GitHub Pages

## Notes

- The backend folder is kept separately for API work; the main deployable frontend is the Flutter app under jobhud/.
- For production web hosting, the GitHub Actions workflow deploys the generated build from jobhud/build/web/.
