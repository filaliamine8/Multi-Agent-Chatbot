@echo off
echo ========================================
echo   Multi-Agent Chatbot Setup
echo ========================================
echo.

REM Check Docker
echo [1/3] Checking Docker...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker is not installed or not running!
    echo Please install Docker Desktop from: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)
echo   ✅ Docker is installed

REM Check Python
echo [2/3] Checking Python...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python is not installed!
    echo Please install Python from: https://www.python.org/downloads/
    pause
    exit /b 1
)
echo   ✅ Python is installed

REM Install dependencies
echo [3/3] Installing Python dependencies...
pip install -r requirements.txt
if %errorlevel% neq 0 (
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)
echo   ✅ Dependencies installed

echo.
echo ========================================
echo   Setup Complete!
echo ========================================
echo.
echo To start the application:
echo   make run
echo.
echo Or manually:
echo   docker-compose up -d
echo   python server_docker.py
echo.
pause
