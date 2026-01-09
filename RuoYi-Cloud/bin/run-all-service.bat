@echo off
echo.
echo [信息] 启动所有后台服务...
echo.

%~d0
cd %~dp0

start "Gateway" cmd /c "run-gateway.bat"
timeout /t 3
start "Auth" cmd /c "run-auth.bat"
timeout /t 3
start "System" cmd /c "run-modules-system.bat"
timeout /t 5

:: 启动医院业务模块
start "Hospital-Modules" cmd /c "run-modules-hospital.bat"

echo [信息] 所有服务启动命令已下发
pause
