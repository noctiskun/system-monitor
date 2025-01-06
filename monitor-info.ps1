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
    Write-Host "Python is required but not detected. Attempting to install..." -ForegroundColor Yellow
    try {
        winget install -e --id Python.Python.3.12 --silent
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        Write-Host "Python installed successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to install Python automatically. Please install from https://www.python.org/downloads/" -ForegroundColor Red
        Start-Process "https://www.python.org/downloads/"
        throw
    }
}

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
            if ($LASTEXITCODE -ne 0) {
                Write-Host "Error installing $package: $result" -ForegroundColor Red
            }
            else {
                Write-Host "Successfully installed $package" -ForegroundColor Green
            }
        }
        catch {
            Write-Host "Error installing $package: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

function Get-SystemInformation {
    $scriptUrl = "https://raw.githubusercontent.com/noctiskun/system-monitor/main/system_info.py"
    try {
        $script = (Invoke-WebRequest -Uri $scriptUrl -UseBasicParsing).Content
        $tempScriptPath = [System.IO.Path]::GetTempFileName() + ".py"
        $script | Out-File -FilePath $tempScriptPath -Encoding utf8
        $result = python $tempScriptPath
        return $result
    }
    catch {
        Write-Host "Error collecting system information: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
    finally {
        if (Test-Path $tempScriptPath) {
            Remove-Item $tempScriptPath -Force
        }
    }
}

try {
    if (-not (Test-PythonInstallation)) {
        Install-Python
    }

    Install-RequiredPackages

    $systemInfo = Get-SystemInformation
    if ($systemInfo) {
        $systemInfo | Set-Clipboard
        Write-Host "`nSystem information has been copied to clipboard." -ForegroundColor Green
        Write-Host $systemInfo
    }
}
catch {
    Write-Host "An error occurred during execution: $($_.Exception.Message)" -ForegroundColor Red
}
