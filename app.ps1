function Initialize-CyberSabilConsole {
    try {
        [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
        $script:OutputEncoding = [Console]::OutputEncoding
    } catch {}

    try {
        chcp 65001 | Out-Null
    } catch {}

    try {
        $Host.UI.RawUI.WindowTitle = "CyberSabil TM Setup"

        $raw = $Host.UI.RawUI
        $targetWidth = [Math]::Min(120, $raw.MaxWindowSize.Width)

        if ($raw.BufferSize.Width -lt $targetWidth) {
            $raw.BufferSize = New-Object System.Management.Automation.Host.Size(
                $targetWidth,
                $raw.BufferSize.Height
            )
        }

        if ($raw.WindowSize.Width -lt $targetWidth) {
            $targetHeight = [Math]::Min(
                [Math]::Max(30, $raw.WindowSize.Height),
                $raw.MaxWindowSize.Height
            )

            $raw.WindowSize = New-Object System.Management.Automation.Host.Size(
                $targetWidth,
                $targetHeight
            )
        }
    } catch {}
}

Initialize-CyberSabilConsole
Clear-Host

# Quick elevation guard BEFORE banner output
# This prevents the first non-admin PowerShell window from getting stuck on the banner.
$QuickIsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole] "Administrator"
)

if (-not $QuickIsAdmin) {
    try {
        if ($PSCommandPath) {
            Start-Process -FilePath "powershell.exe" -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
            exit 0
        } else {
            Write-Host "ERROR: Please run this script as Administrator." -ForegroundColor Red
            Read-Host "Press Enter to close"
            exit 1
        }
    } catch {
        Write-Host "ERROR: Failed to open Administrator PowerShell." -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        Read-Host "Press Enter to close"
        exit 1
    }
}

try {
    chcp 65001 | Out-Null
    [Console]::InputEncoding  = [System.Text.Encoding]::UTF8
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8

    $raw = $host.UI.RawUI
    $safeWidth = [Math]::Min(120, $raw.MaxWindowSize.Width)

    $size = $raw.BufferSize
    if ($size.Width -lt $safeWidth) {
        $size.Width = $safeWidth
        $raw.BufferSize = $size
    }
} catch {}

Clear-Host

$BannerBase64 = @'
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgIOKWiOKWiOKWiOKWiOKWiOKWiOKVl+KWiOKWiOKVlyAgIOKWiOKWiOKVl+KWiOKWiOKWiOKWiOKWiOKWiOKVlyDilojilojilojilojilojilojilojilZfilojilojilojilojilojilojilZcgICAgICDilojilojilojilojilojilojilojilZcg4paI4paI4paI4paI4paI4pWXIOKWiOKWiOKWiOKWiOKWiOKWiOKVlyDilojilojilZfilojilojilZcgICAgICAgICAgICAgICAgICAgIAogIOKWiOKWiOKVlOKVkOKVkOKVkOKVkOKVneKVmuKWiOKWiOKVlyDilojilojilZTilZ3ilojilojilZTilZDilZDilojilojilZfilojilojilZTilZDilZDilZDilZDilZ3ilojilojilZTilZDilZDilojilojilZcgICAgIOKWiOKWiOKVlOKVkOKVkOKVkOKVkOKVneKWiOKWiOKVlOKVkOKVkOKWiOKWiOKVl+KWiOKWiOKVlOKVkOKVkOKWiOKWiOKVl+KWiOKWiOKVkeKWiOKWiOKVkSAgICAgICAgICAgICAgICAgICAgCiAg4paI4paI4pWRICAgICAg4pWa4paI4paI4paI4paI4pWU4pWdIOKWiOKWiOKWiOKWiOKWiOKWiOKVlOKVneKWiOKWiOKWiOKWiOKWiOKVlyAg4paI4paI4paI4paI4paI4paI4pWU4pWdICAgICDilojilojilojilojilojilojilojilZfilojilojilojilojilojilojilojilZHilojilojilojilojilojilojilZTilZ3ilojilojilZHilojilojilZEgICAgICAgICAgICAgICAgICAgIAogIOKWiOKWiOKVkSAgICAgICDilZrilojilojilZTilZ0gIOKWiOKWiOKVlOKVkOKVkOKWiOKWiOKVl+KWiOKWiOKVlOKVkOKVkOKVnSAg4paI4paI4pWU4pWQ4pWQ4paI4paI4pWXICAgICDilZrilZDilZDilZDilZDilojilojilZHilojilojilZTilZDilZDilojilojilZHilojilojilZTilZDilZDilojilojilZfilojilojilZHilojilojilZEgICAgICAgICAgICAgICAgICAgIAogIOKVmuKWiOKWiOKWiOKWiOKWiOKWiOKVlyAgIOKWiOKWiOKVkSAgIOKWiOKWiOKWiOKWiOKWiOKWiOKVlOKVneKWiOKWiOKWiOKWiOKWiOKWiOKWiOKVl+KWiOKWiOKVkSAg4paI4paI4pWRICAgICDilojilojilojilojilojilojilojilZHilojilojilZEgIOKWiOKWiOKVkeKWiOKWiOKWiOKWiOKWiOKWiOKVlOKVneKWiOKWiOKVkeKWiOKWiOKWiOKWiOKWiOKWiOKWiOKVlyAgICAgICAgICAgICAgIAogICDilZrilZDilZDilZDilZDilZDilZ0gICDilZrilZDilZ0gICDilZrilZDilZDilZDilZDilZDilZ0g4pWa4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWd4pWa4pWQ4pWdICDilZrilZDilZ0gICAgIOKVmuKVkOKVkOKVkOKVkOKVkOKVkOKVneKVmuKVkOKVnSAg4pWa4pWQ4pWd4pWa4pWQ4pWQ4pWQ4pWQ4pWQ4pWdIOKVmuKVkOKVneKVmuKVkOKVkOKVkOKVkOKVkOKVkOKVnSAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCj09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0=
'@

$BannerBase64 = $BannerBase64 -replace '\s',''
$Banner = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($BannerBase64))

$BannerLines = $Banner -split "`r?`n"
$BannerWidth = 0
foreach ($line in $BannerLines) {
    if ($line.Length -gt $BannerWidth) { $BannerWidth = $line.Length }
}

function Show-CyberSabilBanner {
    param(
        [ConsoleColor]$Color = [ConsoleColor]::Cyan
    )

    Write-Host ""
    foreach ($line in $BannerLines) {
        Write-Host ($line.PadRight($BannerWidth)) -ForegroundColor $Color
    }
    Write-Host ""
}

function Stop-ScriptWithStatus {
    param(
        [int]$Code = 1,
        [string]$Message = "Script stopped."
    )
    Write-Host ""
    Write-Host $Message -ForegroundColor Red
    Show-CyberSabilBanner -Color Red
    Write-Host ""
    Read-Host "Press Enter to close"
    exit $Code
}

function Write-Utf8NoBomFile {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Value
    )

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Value, $utf8NoBom)
}

trap {
    Write-Host ""
    Write-Host "UNEXPECTED ERROR:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Show-CyberSabilBanner -Color Red
    Write-Host ""
    Read-Host "Press Enter to close"
    exit 1
}

Show-CyberSabilBanner -Color Cyan

# =====================================================
# TrafficMonitor Full Setup - Updated Final
# Download + Extract + AppData Active Config + Auto Startup
# Uses real active config path: %APPDATA%\TrafficMonitor\config.ini
# Taskbar setup copied from manual working config
# No 5-sec watchdog
# No PowerShell startup flash
# =====================================================

$DownloadUrl = "https://github.com/zhongyang219/TrafficMonitor/releases/download/V1.86/TrafficMonitor_V1.86_x64.zip"

$InstallDir = "C:\TrafficMonitor"
$TempDir = "$env:TEMP\TrafficMonitor_Full_Setup"
$ZipPath = "$TempDir\TrafficMonitor_Full.zip"
$ExtractDir = "$TempDir\Extracted"

$Exe = "$InstallDir\TrafficMonitor.exe"
$ProgramConfig = "$InstallDir\config.ini"
$GlobalConfig = "$InstallDir\global_cfg.ini"

$AppDataTrafficDir = Join-Path $env:APPDATA "TrafficMonitor"
$AppDataConfig = Join-Path $AppDataTrafficDir "config.ini"

$TaskName = "Start TrafficMonitor Direct"

Write-Host "===== TrafficMonitor Updated Final Setup Started =====" -ForegroundColor Cyan

# Admin check
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole] "Administrator"
)

if (-not $IsAdmin) {
    if ($PSCommandPath) {
        Start-Process -FilePath "powershell.exe" -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        exit 0
    } else {
        Stop-ScriptWithStatus -Code 1 -Message "ERROR: Please run this script as Administrator."
    }
}

# Stop existing TrafficMonitor
Write-Host "Stopping existing TrafficMonitor..." -ForegroundColor Yellow
Get-Process TrafficMonitor -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Remove old TrafficMonitor startup methods
Write-Host "Removing old TrafficMonitor startup methods..." -ForegroundColor Yellow
Get-ScheduledTask -ErrorAction SilentlyContinue |
Where-Object {
    $_.TaskName -like "*TrafficMonitor*" -or
    $_.TaskPath -like "*TrafficMonitor*" -or
    (($_.Actions | Out-String) -like "*TrafficMonitor*")
} |
ForEach-Object {
    Unregister-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -Confirm:$false -ErrorAction SilentlyContinue
}

Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "TrafficMonitor" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "TrafficMonitor" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run" -Name "TrafficMonitor" -ErrorAction SilentlyContinue

Remove-Item "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\TrafficMonitor.lnk" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Start-TrafficMonitor.vbs" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Start-TrafficMonitor.cmd" -Force -ErrorAction SilentlyContinue

# Remove old watchdog files
Write-Host "Removing old watchdog files..." -ForegroundColor Yellow
Remove-Item "$InstallDir\Keep-TrafficMonitor.ps1" -Force -ErrorAction SilentlyContinue
Remove-Item "$InstallDir\Start-Keep-TrafficMonitor-Hidden.vbs" -Force -ErrorAction SilentlyContinue

# Prepare temp folder
Write-Host "Preparing temp folder..." -ForegroundColor Yellow
Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
New-Item -ItemType Directory -Path $ExtractDir -Force | Out-Null

# Download full version
Write-Host "Downloading TrafficMonitor FULL x64 version..." -ForegroundColor Yellow
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

try {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $ZipPath -UseBasicParsing
} catch {
    Write-Host "ERROR: Download failed." -ForegroundColor Red
    Write-Host $_.Exception.Message
    Stop-ScriptWithStatus -Code 1 -Message "ERROR: Script stopped due to the issue shown above."
}

if (!(Test-Path $ZipPath)) {
    Write-Host "ERROR: ZIP not downloaded." -ForegroundColor Red
    Stop-ScriptWithStatus -Code 1 -Message "ERROR: Script stopped due to the issue shown above."
}

# Backup existing install folder
if (Test-Path $InstallDir) {
    $BackupDir = "C:\TrafficMonitor_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Write-Host "Backing up old TrafficMonitor folder to $BackupDir" -ForegroundColor Yellow
    Move-Item $InstallDir $BackupDir -Force
}

# Extract
Write-Host "Extracting ZIP..." -ForegroundColor Yellow
try {
    Expand-Archive -Path $ZipPath -DestinationPath $ExtractDir -Force
} catch {
    Write-Host "ERROR: Extract failed." -ForegroundColor Red
    Write-Host $_.Exception.Message
    Stop-ScriptWithStatus -Code 1 -Message "ERROR: Script stopped due to the issue shown above."
}

$ExtractedExe = Get-ChildItem $ExtractDir -Recurse -Filter "TrafficMonitor.exe" | Select-Object -First 1

if ($null -eq $ExtractedExe) {
    Write-Host "ERROR: TrafficMonitor.exe not found after extraction." -ForegroundColor Red
    Stop-ScriptWithStatus -Code 1 -Message "ERROR: Script stopped due to the issue shown above."
}

$SourceFolder = $ExtractedExe.Directory.FullName

# Copy to C:\TrafficMonitor
Write-Host "Copying full TrafficMonitor to C:\TrafficMonitor..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
Copy-Item "$SourceFolder\*" $InstallDir -Recurse -Force

if (!(Test-Path $Exe)) {
    Write-Host "ERROR: TrafficMonitor.exe not found in C:\TrafficMonitor." -ForegroundColor Red
    Stop-ScriptWithStatus -Code 1 -Message "ERROR: Script stopped due to the issue shown above."
}

# Unblock and permissions
Write-Host "Unblocking files..." -ForegroundColor Yellow
Get-ChildItem $InstallDir -Recurse -File -ErrorAction SilentlyContinue | Unblock-File -ErrorAction SilentlyContinue

Write-Host "Giving current user permission..." -ForegroundColor Yellow
icacls $InstallDir /grant "$($env:USERNAME):(OI)(CI)F" /T | Out-Null

# Force AppData config mode
# portable_mode=false means TrafficMonitor uses %APPDATA%\TrafficMonitor\config.ini
Write-Host "Setting TrafficMonitor to use AppData config mode..." -ForegroundColor Yellow

$GlobalCfgContent = @'
[config]
portable_mode = false
'@

Write-Utf8NoBomFile -Path $GlobalConfig -Value $GlobalCfgContent

# Prepare AppData config folder
New-Item -ItemType Directory -Path $AppDataTrafficDir -Force | Out-Null

# Backup old AppData config if present
if (Test-Path $AppDataConfig) {
    Copy-Item $AppDataConfig "$AppDataConfig.backup_updated_setup_$(Get-Date -Format 'yyyyMMdd_HHmmss')" -Force -ErrorAction SilentlyContinue
}

# Apply manual working config to active AppData config
Write-Host "Applying working manual config to AppData active config..." -ForegroundColor Yellow

$WorkingConfig = @'
[general]
check_update_when_start = true
language = 0
update_source = 0
show_all_interface = false
cpu_usage_acquire_method = 1
monitor_time_span = 1000
hard_disk_name = _Total
cpu_core_name = Core Average
hardware_monitor_item = 0
connections_hide = 
[config]
transparency = 80
always_on_top = true
lock_window_pos = false
show_notify_icon = true
show_cpu_memory = false
mouse_penetrate = false
show_task_bar_wnd = true
position_x = 913
position_y = 441
hide_main_window = 1
skin_selected = 
notify_icon_selected = 0
notify_icon_auto_adapt = true
swap_up_down = false
hide_main_wnd_when_fullscreen = true
speed_short_mode = false
separate_value_unit_with_space = true
show_tool_tip = true
memory_display = 0
unit_byte = true
speed_unit = 0
hide_unit = false
hide_percent = false
double_click_action = 0
double_click_exe = C:\Windows\system32\Taskmgr.exe
alow_out_of_border = 0
plugin_disabled = 
[connection]
auto_select = true
select_all = false
connection_name = Qualcomm QCA9377 802.11ac Wireless Adapter
[skins]
skin_auto_adapt = false
skin_name_dark_mode = 
skin_name_light_mode = 
[notify_tip]
traffic_tip_enable = false
traffic_tip_value = 200
traffic_tip_unit = 0
memory_usage_tip_enable = false
memory_tip_value = 80
cpu_temperature_tip_enable = false
cpu_temperature_tip_value = 80
gpu_temperature_tip_enable = false
gpu_temperature_tip_value = 80
hdd_temperature_tip_enable = false
hdd_temperature_tip_value = 80
mainboard_temperature_tip_enable = false
mainboard_temperature_tip_value = 80
[task_bar]
task_bar_back_color = 0
transparent_color = 0
status_bar_color = 5921370
task_bar_text_color = 16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,
specify_each_item_color = false
tbar_display_item = 543
font_name = Segoe UI
font_size = 9
font_style = 0
show_taskbar_wnd_in_secondary_display = false
secondary_display_index = 0
up_string = "↑: "
down_string = "↓: "
cpu_string = "CPU: "
memory_string = "MEM: "
gpu_string = "GPU: "
cpu_temp_string = "CPU: "
gpu_temp_string = "GPU: "
hdd_temp_string = "HDD: "
main_board_temp_string = "MBD: "
hdd_string = "HDD: "
total_speed_string = "↑↓: "
cpu_freq_string = "CPU Freq: "
today_traffic_string = "Total traffic: "
task_bar_wnd_on_left = false
task_bar_wnd_snap = false
task_bar_speed_short_mode = false
unit_byte = true
task_bar_speed_unit = 0
task_bar_hide_unit = false
task_bar_hide_percent = false
value_right_align = true
horizontal_arrange = false
show_status_bar = false
separate_value_unit_with_space = true
show_tool_tip = true
digits_number = 4
memory_display = 0
double_click_action = 0
double_click_exe = C:\Windows\system32\Taskmgr.exe
cm_graph_type = true
show_graph_dashed_box = false
item_space = 8
vertical_margin = 0
window_offset_top = 0
window_offset_left = 0
avoid_overlap_with_widgets = false
taskbar_left_space_win11 = 160
taskbar_right_space_win11 = 280
auto_adapt_light_theme = false
dark_default_style = 0
light_default_style = 3
auto_set_background_color = false
item_order = 0,1,2,3,4,9,10,11,12,5,6,7,8
plugin_display_item = 
auto_save_taskbar_color_settings_to_preset = true
show_netspeed_figure = false
netspeed_figure_max_value = 512
netspeed_figure_max_value_unit = 0
graph_color_following_system = false
disable_d2d = true
enable_colorful_emoji = true
[histroy_traffic]
use_log_scale = true
sunday_first = true
view_type = 0
[other]
no_multistart_warning = false
exit_when_start_by_restart_manager = true
debug_log = false
notify_interval = 60
taksbar_transparent_color_enable = true
last_light_mode = false
show_mouse_panetrate_tip = true
show_dot_net_notinstalled_tip = true
[app]
version = 1.86
[taskbar_default_style]
default1_text_color = 16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,16777215,
default1_back_color = 0
default1_transparent_color = 0
default1_status_bar_color = 5921370
default1_specify_each_item_color = false
default2_text_color = 4574711,16777215,5107653,16777215,16632499,16777215,16494036,16777215,14601983,16777215,16760992,10221779,13425662,16777215,4574711,16777215,4574711,4574711,4574711,4574711,4574711,4574711,4574711,4574711,4574711,4574711,
default2_back_color = 0
default2_transparent_color = 0
default2_status_bar_color = 5921370
default2_specify_each_item_color = true
default3_text_color = 31957,0,2533120,0,13857281,0,14354551,0,1145775,0,4328380,0,167504,0,31957,0,31957,31957,31957,31957,31957,31957,31957,31957,31957,31957,
default3_back_color = 13882066
default3_transparent_color = 13882066
default3_status_bar_color = 10855845
default3_specify_each_item_color = true
default4_text_color = 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
default4_back_color = 13882066
default4_transparent_color = 13882066
default4_status_bar_color = 10855845
default4_specify_each_item_color = false
[window_size]
SetItemOrderDlg_width = -1
SetItemOrderDlg_height = -1
'@

Write-Utf8NoBomFile -Path $AppDataConfig -Value $WorkingConfig

# Also keep same config in C:\TrafficMonitor\config.ini for reference/fallback
Write-Utf8NoBomFile -Path $ProgramConfig -Value $WorkingConfig

# Make sure current user has AppData config permission
icacls $AppDataTrafficDir /grant "$($env:USERNAME):(OI)(CI)F" /T | Out-Null

# Create direct startup scheduled task
Write-Host "Creating direct startup scheduled task for current user..." -ForegroundColor Yellow

$Action = New-ScheduledTaskAction -Execute $Exe -WorkingDirectory $InstallDir
$Trigger = New-ScheduledTaskTrigger -AtLogOn -User "$env:USERDOMAIN\$env:USERNAME"

$Principal = New-ScheduledTaskPrincipal `
    -UserId "$env:USERDOMAIN\$env:USERNAME" `
    -LogonType Interactive `
    -RunLevel Highest

$Settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -MultipleInstances IgnoreNew `
    -ExecutionTimeLimit (New-TimeSpan -Hours 0)

Register-ScheduledTask `
    -TaskName $TaskName `
    -Action $Action `
    -Trigger $Trigger `
    -Principal $Principal `
    -Settings $Settings `
    -Description "Start TrafficMonitor directly at login without PowerShell startup window." `
    -Force | Out-Null

# Start TrafficMonitor
Write-Host "Starting TrafficMonitor..." -ForegroundColor Yellow
Start-ScheduledTask -TaskName $TaskName
Start-Sleep -Seconds 6

# Cleanup temp
Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "===== Final Check =====" -ForegroundColor Cyan

Write-Host "Current user:"
Write-Host "$env:USERDOMAIN\$env:USERNAME"

Write-Host ""
Write-Host "Install path:"
Write-Host $InstallDir

Write-Host ""
Write-Host "EXE exists:"
Test-Path $Exe

Write-Host ""
Write-Host "Global config mode:"
Get-Content $GlobalConfig -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Active AppData config path:"
Write-Host $AppDataConfig

Write-Host ""
Write-Host "Important active config values:"
Get-Content $AppDataConfig | Select-String -Pattern "^\[config\]|^\[general\]|^\[connection\]|^\[task_bar\]|portable_mode|show_task_bar_wnd|hide_main_window|always_on_top|show_cpu_memory|mouse_penetrate|lock_window_pos|hardware_monitor_item|tbar_display_item|up_string|down_string|cpu_string|memory_string|gpu_string|total_speed_string|taskbar_left_space_win11|taskbar_right_space_win11"

Write-Host ""
Write-Host "Startup task:"
Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue | Select-Object TaskName, State

Write-Host ""
Write-Host "Task info:"
Get-ScheduledTaskInfo -TaskName $TaskName -ErrorAction SilentlyContinue | Select-Object LastRunTime, LastTaskResult, NextRunTime

Write-Host ""
Write-Host "Running process:"
Get-Process TrafficMonitor -ErrorAction SilentlyContinue | Select-Object ProcessName, Id, Path

Write-Host ""
Write-Host "===== Done =====" -ForegroundColor Green
Write-Host "Updated setup applied successfully."
Write-Host "Active config is now: $AppDataConfig"
Write-Host "No 5-second watchdog created."
Write-Host "No PowerShell startup script created."

Write-Host ""
Show-CyberSabilBanner -Color Red
Write-Host ""
Write-Host "Setup completed. Window will close only after key press." -ForegroundColor Green
Read-Host "Press Enter to close"
