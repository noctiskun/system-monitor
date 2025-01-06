$ErrorActionPreference = 'Stop'

# Check if Python is installed
function Test-PythonInstallation {
    try {
        $pythonVersion = python --version 2>&1
        return $pythonVersion -match "Python"
    }
    catch {
        return $false
    }
}

# Install Python if not detected
function Install-Python {
    Write-Host "Python is required but not detected. Attempting to install..." -ForegroundColor Yellow
    
    try {
        # Uses winget to install Python
        winget install -e --id Python.Python.3.12 --silent
        
        # Refresh environment variables
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        Write-Host "Python installed successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to install Python. Please download and install from https://www.python.org/downloads/" -ForegroundColor Red
        Start-Process "https://www.python.org/downloads/"
        throw
    }
}

# Install required Python packages
function Install-RequiredPackages {
    $packages = @(
        "psutil",
        "wmi",
        "GPUtil",
        "screeninfo",
        "pywin32"
    )

    foreach ($package in $packages) {
        try {
            Write-Host "Installing $package..." -ForegroundColor Yellow
            $result = python -m pip install $package 2>&1
            Write-Host "Successfully installed $package" -ForegroundColor Green
        }
        catch {
            Write-Host "Error installing $package: $_" -ForegroundColor Red
        }
    }
}

# Collect system information
function Get-SystemInformation {
    $scriptUrl = "https://raw.githubusercontent.com/noctiskun/system-monitor/main/system_info.py"
    $script = (Invoke-WebRequest -Uri $scriptUrl -UseBasicParsing).Content

    try {
        $result = python -c $script
        return $result
    }
    catch {
        Write-Host "Error collecting system information: $_" -ForegroundColor Red
        return $null
    }
}

# Main execution
try {
    # Check Python installation, install if not detected
    if (-not (Test-PythonInstallation)) {
        Install-Python
    }

    # Install required packages
    Install-RequiredPackages

    # Collect and copy system information
    $systemInfo = Get-SystemInformation
    if ($systemInfo) {
        $systemInfo | Set-Clipboard
        Write-Host "`nSystem information has been copied to clipboard." -ForegroundColor Green
        Write-Host $systemInfo
    }
}
catch {
    Write-Host "An error occurred: $_" -ForegroundColor Red
}
