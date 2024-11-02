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
$influxDbUrl = "https://dl.influxdata.com/influxdb/releases/influxdb2-2.7.10-windows.zip"  # Change to the latest version
$shawlReleaseUrl = "https://github.com/mtkennerly/shawl/releases/download/v1.5.1/shawl-v1.5.1-win64.zip"  # Change to the correct URL
$shawlSourceUrl = "https://github.com/mtkennerly/shawl/archive/refs/tags/v1.5.1.zip"  # Change to the correct URL if needed

# Define file paths
$influxDbZip = "$influxDbDir\influxdb.zip"
$shawlReleaseZip = "$shawlDir\shawl_release.zip"
$shawlSourceZip = "$shawlDir\shawl_source.zip"

# Function to download files with progress
function Download-WithProgress {
    param (
        [string]$url,
        [string]$outputPath
    )

    $webClient = New-Object System.Net.WebClient

    # Start the download
    Write-Host "Downloading $url..."
    $webClient.DownloadFile($url, $outputPath)
}

# Start download jobs with progress reporting
Download-WithProgress -url $influxDbUrl -outputPath $influxDbZip
Write-Host "InfluxDB download complete."

Download-WithProgress -url $shawlReleaseUrl -outputPath $shawlReleaseZip
Write-Host "Shawl release download complete."

Download-WithProgress -url $shawlSourceUrl -outputPath $shawlSourceZip
Write-Host "Shawl source code download complete."

# Extract InfluxDB
Expand-Archive -Path $influxDbZip -DestinationPath $influxDbDir

# Extract Shawl
Expand-Archive -Path $shawlReleaseZip -DestinationPath $shawlDir

# Extract Shawl source code
Expand-Archive -Path $shawlSourceZip -DestinationPath $shawlDir

# Move the LICENSE file to the Shawl_bin directory and rename it to LICENSE2
$licenseFile = "$shawlDir\shawl-1.5.1\LICENSE"  # Adjust according to the extracted folder structure
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
