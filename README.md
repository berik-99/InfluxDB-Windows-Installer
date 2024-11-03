# InfluxDB Windows Installer 🚀

**Disclaimer:** This software is not affiliated in any way with the producers of InfluxDB. It is a third-party tool designed to simplify the installation of InfluxDB. All logos, texts, and programs used are the property of InfluxDB and were taken and possibly modified from the official repository [here](https://github.com/influxdata/influxdb), which is licensed under MIT.

## Getting Started 🛠️

To get started with the InfluxDB Windows Installer:

1. **Download the Latest Release**: Visit the [Releases](https://github.com/berik-99/InfluxWindowsInstaller/releases) page of this repository to download the latest version of the installer.
2. **Run the Installer**: Execute the downloaded `.exe` file and follow the on-screen instructions to install and register InfluxDB as a Windows service.

## Build 🔧

**Requirements**
- [Inno Setup](https://jrsoftware.org/isinfo.php)
- [PowerShell Core](https://github.com/PowerShell/PowerShell) ( >v7.4 )

To compile the package yourself, follow these steps:

1. Clone the repository:
   ```
   git clone https://github.com/berik-99/InfluxWindowsInstaller.git
   cd InfluxWindowsInstaller
   ```

2. Run the `download_sources.ps1` script (with PowerShell Core):
   ```
   pwsh ./download_sources.ps1
   ```

3. Make sure you have [Inno Setup](https://jrsoftware.org/isinfo.php) installed on your machine.
4. Open the Inno Setup script (`.iss`) file in Inno Setup and build the installer.
5. The compiled installer will be available in the output folder specified in the script.
   ```
   git clone https://github.com/berik-99/InfluxWindowsInstaller.git
   cd InfluxWindowsInstaller
   ```

2. Make sure you have [Inno Setup](https://jrsoftware.org/isinfo.php) installed on your machine.
3. Open the Inno Setup script (`.iss`) file in Inno Setup and build the installer.
4. The compiled installer will be available in the output folder specified in the script.

## Acknowledgments 🙏

- A big thank you to [Shawl](https://github.com/mtkennerly/shawl) and [Inno Setup](https://jrsoftware.org/isinfo.php) for providing amazing tools that made this project possible! 

## License 📄

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
