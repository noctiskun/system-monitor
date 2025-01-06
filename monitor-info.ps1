# Monitor Information Collector
$ErrorActionPreference = 'Stop'

function Get-SystemInfo {
    $info = @{
        OS = [System.Environment]::OSVersion.VersionString
        Hostname = $env:COMPUTERNAME
        Displays = @()
    }

    # Collect display information using Win32_VideoController
    $displays = Get-WmiObject Win32_VideoController | Where-Object { $_.AdapterRAM -gt 0 }
    foreach ($display in $displays) {
        $displayInfo = @{
            Name = $display.Name
            AdapterRAM = if ($display.AdapterRAM) { "$([math]::Round($display.AdapterRAM / 1GB, 2)) GB" } else { "N/A" }
            DriverVersion = $display.DriverVersion
            Resolution = if ($display.CurrentHorizontalResolution -and $display.CurrentVerticalResolution) { 
                "$($display.CurrentHorizontalResolution) x $($display.CurrentVerticalResolution)" 
            } else { "N/A" }
        }
        $info.Displays += $displayInfo
    }

    # Collect monitor information using Win32_DesktopMonitor
    $monitors = Get-WmiObject Win32_DesktopMonitor
    foreach ($monitor in $monitors) {
        $monitorInfo = @{
            Name = $monitor.Name
            ScreenHeight = $monitor.ScreenHeight
            ScreenWidth = $monitor.ScreenWidth
        }
        $info.Displays += $monitorInfo
    }

    return $info
}

function Export-SystemInfoToClipboard {
    $systemInfo = Get-SystemInfo
    $jsonOutput = $systemInfo | ConvertTo-Json -Depth 5
    $jsonOutput | Set-Clipboard
    return $jsonOutput
}

Export-SystemInfoToClipboard
Write-Host "System information has been copied to clipboard. Please paste it when prompted." -ForegroundColor Green