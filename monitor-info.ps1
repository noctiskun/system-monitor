# Monitor Information Collector
$ErrorActionPreference = 'Stop'

function Test-PythonInstallation {
    try {
        $pythonVersion = python --version 2>&1
        return $pythonVersion -match "Python"
    }
    catch {
        return $false
    }
}

function Install-Python {
    Write-Host "Python is not installed. Attempting to download and install..." -ForegroundColor Yellow
    
    try {
        # Uses winget to install Python
        winget install -e --id Python.Python.3.12 --silent
        
        # Refresh environment variables
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        Write-Host "Python installed successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to install Python. Please download and install from python.org manually." -ForegroundColor Red
        Start-Process "https://www.python.org/downloads/"
        throw
    }
}

function Install-PythonPackages {
    # Update pip first
    try {
        Write-Host "Updating pip..." -ForegroundColor Yellow
        python -m pip install --upgrade pip
        Write-Host "Pip updated successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to update pip. Continuing with installations..." -ForegroundColor Yellow
    }

    # Install setuptools first
    try {
        Write-Host "Installing setuptools..." -ForegroundColor Yellow
        pip install setuptools
        Write-Host "Installed setuptools successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to install setuptools. Error: $_" -ForegroundColor Red
    }

    # Install psutil using wheel
    try {
        Write-Host "Installing psutil..." -ForegroundColor Yellow
        pip install psutil --only-binary :all:
        Write-Host "Installed psutil successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to install psutil. Trying alternative method..." -ForegroundColor Yellow
        try {
            pip install --no-cache-dir --no-deps psutil
            Write-Host "Installed psutil successfully using alternative method" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to install psutil. Error: $_" -ForegroundColor Red
        }
    }

    # Install other packages
    $requiredPackages = @(
        "wmi",
        "py-cpuinfo", 
        "GPUtil==1.4.0",
        "screeninfo", 
        "pywin32"
    )
    foreach ($package in $requiredPackages) {
        try {
            pip install $package
            Write-Host "Installed $package successfully" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to install $package. Error: $_" -ForegroundColor Red
        }
    }
}

function Get-SystemInfo {
    $scriptUrl = "https://raw.githubusercontent.com/noctiskun/system-monitor/main/system_info.py"
    $tempScriptPath = "$env:TEMP\system_info.py"
    
    try {
        # Download the script
        Invoke-WebRequest -Uri $scriptUrl -OutFile $tempScriptPath
        
        # Run the Python script and capture output
        $systemInfo = python $tempScriptPath | ConvertFrom-Json
        
        # Remove temporary script
        Remove-Item $tempScriptPath -ErrorAction SilentlyContinue
        
        return $systemInfo
    }
    catch {
        Write-Host "Failed to retrieve system information: $_" -ForegroundColor Red
        return $null
    }
}

function Export-SystemInfoToClipboard {
    Write-Host "System Monitor Information Collector" -ForegroundColor Cyan
    Write-Host "-----------------------------------" -ForegroundColor Cyan
    
    # Ensure Python is installed
    if (-not (Test-PythonInstallation)) {
        Write-Host "Python not detected. Attempting installation..." -ForegroundColor Yellow
        Install-Python
    }
    
    # Install required packages
    Write-Host "Installing required Python packages..." -ForegroundColor Yellow
    Install-PythonPackages
    
    # Collect and copy system info
    Write-Host "Collecting system information..." -ForegroundColor Yellow
    $systemInfo = Get-SystemInfo
    
    if ($systemInfo) {
        $jsonOutput = $systemInfo | ConvertTo-Json -Depth 10
        $jsonOutput | Set-Clipboard
        Write-Host "`nSystem information has been copied to clipboard." -ForegroundColor Green
        Write-Host "Please paste the copied information when prompted." -ForegroundColor Green
        Write-Host "`nDetailed System Information:" -ForegroundColor Cyan
        Write-Host $jsonOutput
        return $jsonOutput
    }
    else {
        Write-Host "Failed to collect system information." -ForegroundColor Red
    }
}

# Run the export function
Export-SystemInfoToClipboard
