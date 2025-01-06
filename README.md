# Monitor Information Collector

## One-Line Installation

```powershell
iwr -useb https://raw.githubusercontent.com/[YOUR_USERNAME]/[YOUR_REPO]/main/monitor-info.ps1 | iex
```

## Purpose

This script collects system and display information and automatically copies it to your clipboard for easy sharing.

## What It Does

- Gathers information about:
  - Operating System
  - Hostname
  - Displays and Monitors
- Copies collected information to clipboard in JSON format
- Provides a simple, one-command execution method

## Security Notes

- Only run scripts from trusted sources
- Review the script content before execution
- Requires PowerShell execution policy that allows running scripts

## Troubleshooting

- Ensure you're running PowerShell with appropriate permissions
- Check your internet connection
- Verify you have WMI (Windows Management Instrumentation) enabled
