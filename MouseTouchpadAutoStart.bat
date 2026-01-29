@echo off
chcp 65001 >nul 2>&1
title 鼠标触控板自动控制-开机自启

:: 1. 检查是否以管理员身份运行
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo 请求管理员权限...
    goto UACPrompt
) else (
    goto Admin
)

:UACPrompt
:: 2. 以管理员身份重新启动批处理
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
exit /B

:Admin
:: 3. 删除临时文件
if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs"

:: 4. 运行PowerShell脚本（替换成你的脚本实际路径！）
echo 正在运行鼠标触控板自动控制脚本...
powershell -NoProfile -ExecutionPolicy Bypass -File "D:\HONORDOWNLOAD\Enable mouse connection while disabling the touchpad\MouseTouchpadControl.ps1"

:: 5. 防闪退（可选：如果想看到执行结果，保留下面这行；想后台运行则删除）
echo 脚本执行完成，按任意键退出...
exit
pause >nul