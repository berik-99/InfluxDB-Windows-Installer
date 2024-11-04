#Requires -PSEdition Core

# Define the destination directories
$influxDbDir = "InfluxDb_bin"
$shawlDir = "Shawl_bin"

# Remove existing directories if they exist
if (Test-Path $influxDbDir) {
    Remove-Item -Path $influxDbDir -Recurse -Force
}
if (Test-Path $shawlDir) {
    Remove-Item -Path $shawlDir -Recurse -Force
}

# Create the directories
New-Item -ItemType Directory -Path $influxDbDir
New-Item -ItemType Directory -Path $shawlDir

# Download URLs
$influxDbUrl = "https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.10-windows.zip"
$shawlReleaseUrl = "https://github.com/mtkennerly/shawl/releases/download/v1.5.1/shawl-v1.5.1-win64.zip"
$shawlSourceUrl = "https://github.com/mtkennerly/shawl/archive/refs/tags/v1.5.1.zip"

# Define file paths
$influxDbZip = "$influxDbDir\influxdb.zip"
$shawlReleaseZip = "$shawlDir\shawl_release.zip"
$shawlSourceZip = "$shawlDir\shawl_source.zip"

# Function to download files with progress
function Get-FileWithProgress {
    param (
        [string]$url,
        [string]$outputPath
    )

    # Initialize the WebClient
    $webClient = New-Object System.Net.WebClient

    # Define the event handler for progress
    $ProgressChanged = {
        param ($sender, $e)
        Write-Progress -Activity "Downloading $url" -Status "$($e.ProgressPercentage)% Complete" -PercentComplete $e.ProgressPercentage
    }

    # Attach the event handler
    $webClient.DownloadProgressChanged.Add($ProgressChanged)

    # Start the download
    Write-Host "Downloading $url..."
    $webClient.DownloadFileAsync([Uri]$url, $outputPath)

    # Wait for download to complete
    while ($webClient.IsBusy) {
        Start-Sleep -Milliseconds 100
    }

    # Clean up the event handler and dispose of the WebClient
    $webClient.DownloadProgressChanged.Remove($ProgressChanged)
    $webClient.Dispose()
    Write-Progress -Activity "Download" -Completed
}

# Start download jobs with progress reporting
Get-FileWithProgress -url $influxDbUrl -outputPath $influxDbZip
Write-Host "InfluxDB download complete."

Get-FileWithProgress -url $shawlReleaseUrl -outputPath $shawlReleaseZip
Write-Host "Shawl release download complete."

Get-FileWithProgress -url $shawlSourceUrl -outputPath $shawlSourceZip
Write-Host "Shawl source code download complete."

# Extract InfluxDB
Expand-Archive -Path $influxDbZip -DestinationPath $influxDbDir

# Extract Shawl
Expand-Archive -Path $shawlReleaseZip -DestinationPath $shawlDir

# Extract Shawl source code
Expand-Archive -Path $shawlSourceZip -DestinationPath $shawlDir

# Move the LICENSE file to the Shawl_bin directory and rename it to LICENSE2
$licenseFile = "$shawlDir\shawl-1.5.1\LICENSE"
if (Test-Path $licenseFile) {
    Rename-Item -Path $licenseFile -NewName "LICENSE2"
    Move-Item -Path "$shawlDir\shawl-1.5.1\LICENSE2" -Destination $shawlDir
}

# Clean up the zip files
Remove-Item $influxDbZip
Remove-Item $shawlReleaseZip
Remove-Item $shawlSourceZip
Remove-Item "$shawlDir\shawl-1.5.1" -Recurse -Force

Write-Host "Download and copy completed!"
