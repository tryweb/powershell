# PowerShell Linux Command Aliases

A comprehensive collection of PowerShell functions and aliases that bring familiar Linux command-line tools to Windows PowerShell, enhancing productivity for cross-platform developers and system administrators.

## 🚀 Features

- **grep**: Text search and pattern matching using Select-String
- **top/htop**: Real-time process monitoring with system resource display
- **watch**: Periodic command execution with difference highlighting
- **System monitoring utilities**: File, process, and resource watchers
- **Cross-platform familiarity**: Use Linux commands on Windows seamlessly

## 📋 Table of Contents

- [Installation](#installation)
- [Commands](#commands)
  - [grep](#grep---text-search)
  - [top/htop](#tophtop---process-monitoring)
  - [watch](#watch---periodic-execution)
- [System Monitoring](#system-monitoring)
- [Usage Examples](#usage-examples)
- [Aliases Reference](#aliases-reference)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## 🔧 Installation

### Prerequisites

- Windows PowerShell 5.1+ or PowerShell Core 7+
- Execution policy set to allow scripts

### Setup

1. **Check your PowerShell profile path:**
   ```powershell
   $PROFILE
   ```

2. **Set execution policy (if needed):**
   ```powershell
   # Run as Administrator
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. **Create or edit your PowerShell profile:**
   ```powershell
   # Create profile if it doesn't exist
   if (!(Test-Path -Path $PROFILE)) {
       New-Item -ItemType File -Path $PROFILE -Force
   }
   
   # Edit profile
   notepad $PROFILE
   ```

4. **Add the functions to your profile:**
   Copy the contents from `Microsoft.PowerShell_profile.ps1` to your profile file.

5. **Reload your profile:**
   ```powershell
   . $PROFILE
   ```

## 📚 Commands

### grep - Text Search

Powerful text search using Select-String with Linux-like syntax.

#### Basic Usage
```powershell
# Search in files
grep "pattern" "*.txt"
grep "error" "logfile.log"

# Recursive search
grep "exception" -r

# Case-insensitive search  
grep "ERROR" -i

# Pipeline usage
Get-Content "file.txt" | grep "search term"
```

#### Advanced Options
```powershell
# Count matches
grep "success" -c "*.log"

# Show only filenames
grep "config" -l "*.ini"

# Invert match (exclude pattern)
grep "debug" -v
```

### top/htop - Process Monitoring

Real-time system and process monitoring with customizable display.

#### Basic Usage
```powershell
# Basic process monitoring
top

# Custom parameters
top -Count 10 -Interval 3 -SortBy Memory

# Run once (no continuous updates)
top -Once

# Alternative versions
htop          # Simplified version
pstop         # Static snapshot
topm          # Sort by memory
```

#### Display Options
- **Real-time updates** with customizable intervals
- **Color-coded output** based on resource usage
- **System uptime** and resource information
- **Sortable** by CPU, Memory, or Process Name

### watch - Periodic Execution

Execute commands periodically and monitor changes.

#### Basic Usage
```powershell
# Basic watch
watch "Get-Date"
watch "Get-Process | Select-Object -First 5"

# Custom interval
watch "dir" -Interval 5

# Highlight differences
watch "Get-Process | Measure-Object" -Differences

# Run specific number of times
watch "Get-Date" -Count 5
```

#### Specialized Watchers
```powershell
# Watch file changes
watch-file "C:\logs\app.log"

# Monitor specific processes
watch-process "notepad"

# System resource monitoring
watch-system
```

## 🔍 System Monitoring

### File Monitoring
Monitor file changes and display recent content:
```powershell
wf "C:\logs\application.log"
```

### Process Monitoring
Track specific processes and their resource usage:
```powershell
wp "chrome"
wp "powershell"
```

### System Resource Monitoring
Comprehensive system resource dashboard:
```powershell
ws  # Shows CPU, memory, disk usage, and top processes
```

## 💡 Usage Examples

### Common grep Scenarios
```powershell
# Find errors in log files
grep "ERROR\|FATAL" "C:\logs\*.log" -r

# Search configuration files
grep "database" "*.config" -i

# Exclude debug information
Get-Content "app.log" | grep "debug" -v

# Count occurrences
grep "login" "access.log" -c
```

### Process Monitoring Examples
```powershell
# Monitor high CPU processes
top -SortBy CPU -Count 5

# Watch memory usage
top -SortBy Memory -Interval 1

# Quick process snapshot
pstop -Count 15
```

### Watch Command Examples
```powershell
# Monitor disk space
w "Get-CimInstance Win32_LogicalDisk | Select DeviceID, @{Name='FreeGB'; Expression={[math]::Round(\$_.FreeSpace/1GB,2)}}"

# Watch network connections
w "Get-NetTCPConnection | Where State -eq 'Established' | Measure"

# Monitor service status
w "Get-Service | Where Status -eq 'Running' | Measure"
```

## 📖 Aliases Reference

| Alias | Command | Description |
|-------|---------|-------------|
| `grep` | `Select-String wrapper` | Text search and filtering |
| `top` | `top` | Process monitoring |
| `htop` | `htop` | Simplified process monitor |
| `pstop` | `pstop` | Static process snapshot |
| `topm` | `top -SortBy Memory` | Memory-sorted processes |
| `w` | `watch` | Periodic command execution |
| `wf` | `watch-file` | File change monitoring |
| `wp` | `watch-process` | Process monitoring |
| `ws` | `watch-system` | System resource monitoring |

## 🛠️ Troubleshooting

### Execution Policy Issues
If you get execution policy errors:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Profile Not Loading
Verify your profile path and existence:
```powershell
Test-Path $PROFILE
Get-Content $PROFILE
```

### Commands Not Recognized
Reload your profile:
```powershell
. $PROFILE
```

### Performance Issues
For better performance with large outputs:
```powershell
# Use -Count to limit results
top -Count 10
watch "command" -Interval 5
```

## 🎯 Features Overview

| Feature | grep | top | watch |
|---------|------|-----|-------|
| Real-time updates | ❌ | ✅ | ✅ |
| Pattern matching | ✅ | ❌ | ❌ |
| Customizable intervals | ❌ | ✅ | ✅ |
| Difference highlighting | ❌ | ❌ | ✅ |
| Pipeline support | ✅ | ❌ | ❌ |
| File monitoring | ❌ | ❌ | ✅ |
| Resource usage display | ❌ | ✅ | ✅ |

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Fork the repository**
2. **Create a feature branch:** `git checkout -b feature/new-command`
3. **Commit your changes:** `git commit -m "feat: add new command"`
4. **Push to the branch:** `git push origin feature/new-command`
5. **Submit a Pull Request**

### Ideas for Contributions
- Add more Linux commands (ls, find, tail, head, etc.)
- Improve performance for large datasets
- Add configuration file support
- Enhance error handling
- Add unit tests

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by Linux command-line tools
- Built for the PowerShell community
- Thanks to all contributors

## 📞 Support

If you encounter any issues or have questions:
- Open an issue on GitHub
- Check the [Troubleshooting](#troubleshooting) section
- Review PowerShell documentation

---

**Happy scripting! 🚀**