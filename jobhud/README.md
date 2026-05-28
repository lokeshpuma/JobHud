# JobHUD Frontend

JobHUD is the Flutter frontend for the career-guidance and job-search experience.

## Run locally

1. cd jobhud
2. flutter pub get
3. flutter run -d chrome

## Build for GitHub Pages

flutter build web --release --base-href "/JobHud/"

## Deploy

A GitHub Actions workflow is included in the repository root under .github/workflows/ to publish the web build to GitHub Pages automatically.

## Notes

- This app is the deployable frontend.
- The backend service remains optional for API connectivity.
