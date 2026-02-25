# Stop all running Dart/Flutter processes
Write-Host "Stopping Dart/Flutter processes..."
taskkill /F /IM dart.exe /T 2>&1 | Out-Null
taskkill /F /IM flutter.exe /T 2>&1 | Out-Null

# Wait a moment for processes to fully terminate
Start-Sleep -Seconds 2

# Define directories to clean
$directories = @(
    "$PWD\build",
    "$PWD\.dart_tool",
    "$PWD\ios\Flutter\ephemeral",
    "$PWD\linux\flutter\ephemeral",
    "$PWD\macos\Flutter\ephemeral",
    "$PWD\windows\flutter\ephemeral"
)

# Remove each directory if it exists
foreach ($dir in $directories) {
    if (Test-Path $dir) {
        Write-Host "Removing $dir"
        try {
            Remove-Item -Path $dir -Recurse -Force -ErrorAction Stop
            Write-Host "Successfully removed $dir" -ForegroundColor Green
        } catch {
            Write-Host "Failed to remove $dir : $_" -ForegroundColor Red
        }
    } else {
        Write-Host "$dir does not exist, skipping..." -ForegroundColor Yellow
    }
}

Write-Host "Cleanup complete. Running 'flutter clean'..." -ForegroundColor Cyan
flutter clean

if ($?) {
    Write-Host "Successfully cleaned the Flutter project!" -ForegroundColor Green
} else {
    Write-Host "There were issues cleaning the project. Please check the output above." -ForegroundColor Red
}
