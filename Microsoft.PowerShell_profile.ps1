function grep {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Pattern,
        
        [Parameter(Position=1, ValueFromPipeline=$true)]
        [object]$InputObject,
        
        [string[]]$Path,
        [switch]$r,  # recursive
        [switch]$i,  # ignore case
        [switch]$v,  # invert match
        [switch]$c,  # count
        [switch]$l,  # files with matches
        [switch]$n   # line numbers
    )
    
    process {
        # 如果有管道輸入
        if ($InputObject) {
            if ($v) {
                $InputObject | Where-Object { $_ -notmatch $Pattern }
            } else {
                $InputObject | Where-Object { $_ -match $Pattern }
            }
            return
        }
        
        # 檔案搜尋
        $selectStringParams = @{
            Pattern = $Pattern
        }
        
        if ($Path) {
            $selectStringParams.Path = $Path
        } else {
            $selectStringParams.Path = "*"
        }
        
        if ($r) { $selectStringParams.Recurse = $true }
        if ($i) { $selectStringParams.CaseSensitive = $false }
        
        $result = Select-String @selectStringParams
        
        if ($v) {
            # 反向匹配需要特殊處理
            Get-Content $selectStringParams.Path | Where-Object { $_ -notmatch $Pattern }
        } elseif ($c) {
            $result.Count
        } elseif ($l) {
            ($result | Select-Object -Unique Path).Path
        } else {
            $result
        }
    }
}


# 系統資源概況
function sysinfo {
    $cpu = Get-CimInstance Win32_Processor
    $memory = Get-CimInstance Win32_ComputerSystem
    $os = Get-CimInstance Win32_OperatingSystem
    
    Write-Host "=== 系統資源 ===" -ForegroundColor Green
    Write-Host "CPU: $($cpu.Name)"
    Write-Host "記憶體: $([math]::Round($memory.TotalPhysicalMemory/1GB,2)) GB"
    Write-Host "可用記憶體: $([math]::Round($os.FreePhysicalMemory/1MB,2)) MB"
    Write-Host "運行程序數: $((Get-Process).Count)"
}

# PowerShell Top Functions - Similar to Linux top command

function top {
    param(
        [int]$Count = 20,
        [int]$Interval = 5,
        [string]$SortBy = "CPU",
        [switch]$Once
    )
    
    function Show-Header {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $uptime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
        $uptimeSpan = (Get-Date) - $uptime
        
        Write-Host "PowerShell Top - $timestamp" -ForegroundColor Green
        Write-Host "System Uptime: $($uptimeSpan.Days) days $($uptimeSpan.Hours) hours $($uptimeSpan.Minutes) minutes" -ForegroundColor Yellow
        Write-Host "Press Ctrl+C to exit" -ForegroundColor Red
        Write-Host ("-" * 80) -ForegroundColor Gray
        Write-Host ("{0,-25} {1,8} {2,12} {3,8} {4,10}" -f "Process Name", "PID", "Memory(MB)", "CPU%", "Status") -ForegroundColor Cyan
        Write-Host ("-" * 80) -ForegroundColor Gray
    }
    
    do {
        Clear-Host
        Show-Header
        
        $processes = Get-Process | Where-Object { $_.ProcessName -ne "Idle" }
        
        switch ($SortBy.ToUpper()) {
            "CPU" { $processes = $processes | Sort-Object CPU -Descending }
            "MEMORY" { $processes = $processes | Sort-Object WorkingSet -Descending }
            "NAME" { $processes = $processes | Sort-Object ProcessName }
            default { $processes = $processes | Sort-Object CPU -Descending }
        }
        
        $processes | Select-Object -First $Count | ForEach-Object {
            $memoryMB = [math]::Round($_.WorkingSet / 1MB, 2)
            $cpuPercent = if ($_.CPU) { [math]::Round($_.CPU, 2) } else { 0 }
            
            $color = "White"
            if ($cpuPercent -gt 50) { $color = "Red" }
            elseif ($cpuPercent -gt 20) { $color = "Yellow" }
            
            $processName = if ($_.ProcessName.Length -gt 24) { 
                $_.ProcessName.Substring(0, 21) + "..." 
            } else { 
                $_.ProcessName 
            }
            
            Write-Host ("{0,-25} {1,8} {2,12} {3,8} {4,10}" -f 
                $processName,
                $_.Id,
                $memoryMB,
                $cpuPercent,
                $_.Responding
            ) -ForegroundColor $color
        }
        
        if (-not $Once) {
            Start-Sleep -Seconds $Interval
        }
    } while (-not $Once)
}


function htop {
    param([int]$n = 15)
    
    while ($true) {
        Clear-Host
        Write-Host "=== PowerShell htop ===" -ForegroundColor Green
        Write-Host "Press Ctrl+C to exit" -ForegroundColor Red
        Write-Host ""
        
        Get-Process | 
        Sort-Object CPU -Descending | 
        Select-Object -First $n | 
        Format-Table ProcessName, Id, 
            @{Label="CPU"; Expression={[math]::Round($_.CPU,2)}}, 
            @{Label="Memory(MB)"; Expression={[math]::Round($_.WorkingSet/1MB,2)}},
            @{Label="Threads"; Expression={$_.Threads.Count}} -AutoSize
        
        Start-Sleep -Seconds 5
    }
}

function pstop {
    param(
        [int]$Count = 20,
        [string]$SortBy = "CPU"
    )
    
    $processes = Get-Process
    
    switch ($SortBy.ToUpper()) {
        "CPU" { $processes = $processes | Sort-Object CPU -Descending }
        "MEMORY" { $processes = $processes | Sort-Object WorkingSet -Descending }
        "NAME" { $processes = $processes | Sort-Object ProcessName }
    }
    
    $processes | 
    Select-Object -First $Count |
    Select-Object ProcessName, Id, 
        @{Name="CPU"; Expression={[math]::Round($_.CPU,2)}},
        @{Name="Memory(MB)"; Expression={[math]::Round($_.WorkingSet/1MB,2)}},
        @{Name="Threads"; Expression={$_.Threads.Count}},
        StartTime |
    Format-Table -AutoSize
}

function sysinfo {
    $cpu = Get-CimInstance Win32_Processor
    $memory = Get-CimInstance Win32_ComputerSystem
    $os = Get-CimInstance Win32_OperatingSystem
    
    Write-Host "=== System Resources ===" -ForegroundColor Green
    Write-Host "CPU: $($cpu.Name)"
    Write-Host "Memory: $([math]::Round($memory.TotalPhysicalMemory/1GB,2)) GB"
    Write-Host "Available Memory: $([math]::Round($os.FreePhysicalMemory/1MB,2)) MB"
    Write-Host "Running Processes: $((Get-Process).Count)"
}

# Create aliases
Set-Alias -Name "ps-top" -Value top
Set-Alias -Name "psh-top" -Value htop


# PowerShell Watch Functions - Similar to Linux watch command

function watch {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Command,
        
        [int]$Interval = 2,
        [switch]$Differences,
        [switch]$NoTitle,
        [int]$Count = 0
    )
    
    $runCount = 0
    $previousOutput = ""
    
    while ($true) {
        $runCount++
        
        # 如果指定了執行次數限制
        if ($Count -gt 0 -and $runCount -gt $Count) {
            break
        }
        
        Clear-Host
        
        # 顯示標題（除非使用 -NoTitle）
        if (-not $NoTitle) {
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Write-Host "Every ${Interval}s: $Command" -ForegroundColor Green
            Write-Host "Current Time: $timestamp" -ForegroundColor Yellow
            
            if ($Differences) {
                Write-Host "Highlighting differences" -ForegroundColor Cyan
            }
            
            Write-Host ("-" * 60) -ForegroundColor Gray
        }
        
        try {
            # 執行命令並捕獲輸出
            $currentOutput = Invoke-Expression $Command | Out-String
            
            # 如果啟用差異顯示
            if ($Differences -and $previousOutput) {
                $currentLines = $currentOutput -split "`n"
                $previousLines = $previousOutput -split "`n"
                
                $maxLines = [Math]::Max($currentLines.Count, $previousLines.Count)
                
                for ($i = 0; $i -lt $maxLines; $i++) {
                    $currentLine = if ($i -lt $currentLines.Count) { $currentLines[$i] } else { "" }
                    $previousLine = if ($i -lt $previousLines.Count) { $previousLines[$i] } else { "" }
                    
                    if ($currentLine -ne $previousLine) {
                        Write-Host $currentLine -ForegroundColor Yellow -BackgroundColor DarkRed
                    } else {
                        Write-Host $currentLine
                    }
                }
            } else {
                Write-Host $currentOutput
            }
            
            $previousOutput = $currentOutput
            
        } catch {
            Write-Host "Error executing command: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        Start-Sleep -Seconds $Interval
    }
}

# 簡化版的 watch
function simple-watch {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Command,
        [int]$Seconds = 2
    )
    
    while ($true) {
        Clear-Host
        Write-Host "Watching: $Command (every ${Seconds}s)" -ForegroundColor Green
        Write-Host "Press Ctrl+C to stop" -ForegroundColor Red
        Write-Host ""
        
        try {
            Invoke-Expression $Command
        } catch {
            Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        Start-Sleep -Seconds $Seconds
    }
}

# 監控檔案變化
function watch-file {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path,
        [int]$Interval = 2
    )
    
    if (-not (Test-Path $Path)) {
        Write-Host "File not found: $Path" -ForegroundColor Red
        return
    }
    
    $lastWrite = (Get-Item $Path).LastWriteTime
    
    while ($true) {
        Clear-Host
        Write-Host "Watching file: $Path" -ForegroundColor Green
        Write-Host "Last modified: $lastWrite" -ForegroundColor Yellow
        Write-Host "Current time: $(Get-Date)" -ForegroundColor Cyan
        Write-Host ("-" * 50) -ForegroundColor Gray
        
        $currentWrite = (Get-Item $Path).LastWriteTime
        
        if ($currentWrite -ne $lastWrite) {
            Write-Host "FILE CHANGED!" -ForegroundColor Red -BackgroundColor Yellow
            $lastWrite = $currentWrite
        }
        
        # 顯示檔案內容的最後幾行
        Write-Host "Last 10 lines:" -ForegroundColor Green
        Get-Content $Path -Tail 10
        
        Start-Sleep -Seconds $Interval
    }
}

# 監控程序
function watch-process {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ProcessName,
        [int]$Interval = 2
    )
    
    while ($true) {
        Clear-Host
        Write-Host "Watching processes: $ProcessName" -ForegroundColor Green
        Write-Host "Time: $(Get-Date)" -ForegroundColor Yellow
        Write-Host ("-" * 50) -ForegroundColor Gray
        
        $processes = Get-Process -Name "*$ProcessName*" -ErrorAction SilentlyContinue
        
        if ($processes) {
            $processes | Format-Table ProcessName, Id, CPU, WorkingSet, StartTime -AutoSize
        } else {
            Write-Host "No processes found matching: $ProcessName" -ForegroundColor Red
        }
        
        Start-Sleep -Seconds $Interval
    }
}

# 監控系統資源
function watch-system {
    param([int]$Interval = 2)
    
    while ($true) {
        Clear-Host
        Write-Host "System Resource Monitor" -ForegroundColor Green
        Write-Host "Time: $(Get-Date)" -ForegroundColor Yellow
        Write-Host ("-" * 50) -ForegroundColor Gray
        
        # CPU 資訊
        $cpu = Get-CimInstance Win32_Processor
        Write-Host "CPU: $($cpu.Name)" -ForegroundColor Cyan
        
        # 記憶體資訊
        $os = Get-CimInstance Win32_OperatingSystem
        $totalMemory = [math]::Round($os.TotalVisibleMemorySize / 1KB / 1KB, 2)
        $freeMemory = [math]::Round($os.FreePhysicalMemory / 1KB / 1MB, 2)
        $usedMemory = $totalMemory - $freeMemory
        $memoryPercent = [math]::Round(($usedMemory / $totalMemory) * 100, 2)
        
        Write-Host "Memory: $usedMemory GB / $totalMemory GB ($memoryPercent%)" -ForegroundColor Cyan
        
        # 磁碟空間
        Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 } | ForEach-Object {
            $freeSpace = [math]::Round($_.FreeSpace / 1GB, 2)
            $totalSpace = [math]::Round($_.Size / 1GB, 2)
            $usedSpace = $totalSpace - $freeSpace
            $diskPercent = [math]::Round(($usedSpace / $totalSpace) * 100, 2)
            
            Write-Host "Disk $($_.DeviceID) $usedSpace GB / $totalSpace GB ($diskPercent%)" -ForegroundColor Cyan
        }
        
        # Top 5 程序
        Write-Host "`nTop 5 CPU processes:" -ForegroundColor Green
        Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 | 
        Format-Table ProcessName, CPU, @{Label="Memory(MB)"; Expression={[math]::Round($_.WorkingSet/1MB,2)}} -AutoSize
        
        Start-Sleep -Seconds $Interval
    }
}

# 建立 alias
Set-Alias w watch
Set-Alias wf watch-file
Set-Alias wp watch-process
Set-Alias ws watch-system