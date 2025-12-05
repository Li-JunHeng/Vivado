@echo off
REM Vivado 项目解压缩脚本 (Windows)
REM 使用方法: decompress.bat <压缩文件路径> [目标文件夹]

setlocal enabledelayedexpansion

REM 检查参数
if "%~1"=="" (
    echo [错误] 缺少参数
    echo 使用方法: %~nx0 ^<压缩文件路径^> [目标文件夹]
    echo 示例: %~nx0 project.zip
    echo 示例: %~nx0 project.zip output_folder
    exit /b 1
)

set "SOURCE=%~1"
set "TARGET=%~2"

REM 检查源文件是否存在
if not exist "%SOURCE%" (
    echo [错误] 压缩文件不存在: %SOURCE%
    exit /b 1
)

REM 如果未指定目标文件夹，使用压缩文件名（不含扩展名）
if "%TARGET%"=="" (
    set "TARGET=%~n1"
)

echo 开始解压缩...
echo 源文件: %SOURCE%
echo 目标文件夹: %TARGET%
echo.

REM 检查是否有 PowerShell（Windows 7 及以上都有）
where powershell >nul 2>&1
if %errorlevel% equ 0 (
    REM 使用 PowerShell 解压
    powershell -command "& { Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory('%SOURCE%', '%TARGET%') }"
    
    if !errorlevel! equ 0 (
        echo.
        echo [成功] 解压完成!
        echo 输出文件夹: %TARGET%
        
        REM 显示解压后的文件数量
        for /f %%A in ('dir /b /s "%TARGET%" ^| find /c /v ""') do set COUNT=%%A
        echo 文件数量: !COUNT!
    ) else (
        echo.
        echo [失败] 解压缩失败!
        exit /b 1
    )
) else (
    REM 如果没有 PowerShell，尝试使用 tar（Windows 10 1803 及以上）
    where tar >nul 2>&1
    if !errorlevel! equ 0 (
        if not exist "%TARGET%" mkdir "%TARGET%"
        tar -xf "%SOURCE%" -C "%TARGET%"
        
        if !errorlevel! equ 0 (
            echo.
            echo [成功] 解压完成!
            echo 输出文件夹: %TARGET%
        ) else (
            echo.
            echo [失败] 解压缩失败!
            exit /b 1
        )
    ) else (
        echo [错误] 系统中未找到 PowerShell 或 tar 命令
        echo 请确保使用 Windows 7 或更高版本
        exit /b 1
    )
)

endlocal

