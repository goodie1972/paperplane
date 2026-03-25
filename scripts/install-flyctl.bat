@echo off
chcp 65001 >nul
echo ==========================================
echo Flyctl 手动安装脚本 for Windows
echo ==========================================
echo.

:: 设置安装目录
set FLY_DIR=%USERPROFILE%\.fly\bin
set FLY_BIN=%FLY_DIR%\flyctl.exe

echo 安装目录: %FLY_DIR%
echo.

:: 创建目录
if not exist "%FLY_DIR%" mkdir "%FLY_DIR%"

:: 检查是否已安装
if exist "%FLY_BIN%" (
    echo flyctl 已存在，检查版本...
    "%FLY_BIN%" --version
    goto :end
)

echo 请选择安装方式:
echo 1. 自动下载（需要能访问 GitHub）
echo 2. 手动下载（推荐，如果 GitHub 访问困难）
echo.

set /p choice="输入 1 或 2: "

if "%choice%"=="1" goto :auto_download
if "%choice%"=="2" goto :manual_download

echo 无效选择，退出...
goto :end

:auto_download
echo.
echo 正在尝试从 GitHub 下载最新版本...
echo 下载地址: https://github.com/superfly/flyctl/releases/latest/download/flyctl_Windows_x86_64.zip

:: 使用 PowerShell 下载
powershell -Command "& {$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri 'https://github.com/superfly/flyctl/releases/latest/download/flyctl_Windows_x86_64.zip' -OutFile '%TEMP%\flyctl.zip' -UseBasicParsing}"

if exist "%TEMP%\flyctl.zip" (
    echo 下载成功，正在解压...
    powershell -Command "Expand-Archive -Path '%TEMP%\flyctl.zip' -DestinationPath '%FLY_DIR%' -Force"
    del "%TEMP%\flyctl.zip"
    echo 解压完成
) else (
    echo 自动下载失败，请使用手动方式
echo.
    pause
    goto :manual_download
)

goto :add_to_path

:manual_download
echo.
echo ==========================================
echo 手动下载步骤:
echo ==========================================
echo.
echo 1. 打开浏览器访问:
echo    https://github.com/superfly/flyctl/releases/latest
echo.
echo 2. 找到并下载: flyctl_Windows_x86_64.zip
 echo.
echo 3. 将下载的 ZIP 文件解压到:
echo    %FLY_DIR%
echo.
echo 4. 确保 %FLY_DIR% 包含 flyctl.exe
 echo.
echo 按任意键打开浏览器...
pause >nul
start https://github.com/superfly/flyctl/releases/latest
echo.
echo 下载完成后按任意键继续...
pause >nul

if not exist "%FLY_BIN%" (
    echo 错误: 未找到 flyctl.exe，请确保已正确解压到 %FLY_DIR%
    pause
    exit /b 1
)

goto :add_to_path

:add_to_path
echo.
echo 正在添加到环境变量...

:: 检查是否已在 PATH 中
echo %PATH% | find /i "%FLY_DIR%" >nul
if %errorlevel%==0 (
    echo 已存在 PATH 中，跳过
) else (
    :: 添加到用户 PATH
    setx PATH "%PATH%;%FLY_DIR%"
    echo 已添加到 PATH: %FLY_DIR%
)

echo.
echo ==========================================
echo 安装完成!
echo ==========================================
echo.
echo 请关闭并重新打开终端，然后运行:
echo   fly --version
echo   fly auth login
echo.
echo 如果提示找不到命令，手动添加以下路径到 PATH:
echo   %FLY_DIR%
echo.

:end
pause
