<#
.SYNOPSIS
精准匹配你的鼠标和触控板（硬件ID版）
#>

# 你的鼠标硬件ID标识
$targetMousePatterns = @("VID&0232c2_PID&0012")

# 你的触控板硬件ID（从设备管理器获取）
$touchpadHardwareId = "HID\\VEN_GXTP&DEV_7863&Col02"

# 强制设置执行策略
Set-ExecutionPolicy Bypass -Scope Process -Force -ErrorAction SilentlyContinue

# 管理员权限检查
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 检测鼠标连接状态
function Test-MouseConnection {
    param([array]$Patterns)
    $allMice = Get-PnpDevice -Class Mouse -ErrorAction SilentlyContinue
    foreach ($mouse in $allMice) {
        foreach ($pattern in $Patterns) {
            if ($mouse.HardwareId -match $pattern -and $mouse.Status -eq "OK") {
                Write-Host "✅  Target Mouse Found: $($mouse.FriendlyName)" -ForegroundColor Green
                return $true
            }
        }
    }
    Write-Host "❌  Target Mouse Not Found" -ForegroundColor Red
    return $false
}

# 控制触控板（用硬件ID精准定位）
function Set-TouchpadState {
    param([bool]$Enable, [string]$HardwareId)
    $touchpad = Get-PnpDevice -ErrorAction SilentlyContinue | Where-Object {
        $_.HardwareId -match $HardwareId -and $_.Status -ne $null
    }

    if (-not $touchpad) {
        Write-Host "⚠️  Touchpad not found with hardware ID: $HardwareId" -ForegroundColor Yellow
        return
    }

    $action = if ($Enable) { "Enable" } else { "Disable" }
    Write-Host "📌  Performing action: $action Touchpad ($($touchpad.FriendlyName))" -ForegroundColor Cyan

    try {
        if ($Enable) {
            Enable-PnpDevice -InstanceId $touchpad.InstanceId -Confirm:$false -ErrorAction Stop
            Write-Host "✅  Successfully Enabled Touchpad" -ForegroundColor Green
        } else {
            Disable-PnpDevice -InstanceId $touchpad.InstanceId -Confirm:$false -ErrorAction Stop
            Write-Host "✅  Successfully Disabled Touchpad" -ForegroundColor Green
        }
    } catch {
        Write-Host "❌  Failed to $action Touchpad: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "💡  If this fails due to driver protection, use Windows built-in setting:" -ForegroundColor Yellow
        Write-Host "    Settings > Bluetooth & devices > Touchpad > Keep touchpad on when a mouse is connected" -ForegroundColor Yellow
    }
}

# 主逻辑
Write-Host "===== Mouse-Touchpad Auto Control =====" -ForegroundColor White
$mouseConnected = Test-MouseConnection -Patterns $targetMousePatterns
Set-TouchpadState -Enable (-not $mouseConnected) -HardwareId $touchpadHardwareId

# 防闪退
#Write-Host "`nOperation completed. Press any key to exit..." -ForegroundColor Gray
#$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# 自动关闭窗口（延迟3秒）
#Write-Host "`nOperation completed. Window will close automatically in 3 seconds..." -ForegroundColor Gray
#Start-Sleep -Seconds 0  # 延迟3秒（可修改数字调整延迟时间，比如1秒就写1）

echo 脚本执行完成，按任意键退出...
exit
pause >nul