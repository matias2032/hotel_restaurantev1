@echo off
title Hotel Restaurante Local Launcher

set "ROOT=%~dp0"
set "BACKEND_DIR=%ROOT%hotel-restaurante-backend"
set "FRONTEND_DIR=%ROOT%hotel_restaurante_frontend"

REM =====================================================
REM CONFIGURACAO LOCAL DO POSTGRESQL
REM =====================================================
set "DATABASE_URL=jdbc:postgresql://localhost:5433/hotel-restaurante"
set "DATABASE_USERNAME=postgres"
set "DATABASE_PASSWORD=hx1232"

echo =====================================================
echo   HOTEL + RESTAURANTE - ARRANQUE LOCAL
echo =====================================================
echo.

echo Backend:  %BACKEND_DIR%
echo Frontend: %FRONTEND_DIR%
echo Banco:    %DATABASE_URL%
echo Usuario:  %DATABASE_USERNAME%
echo.

if not exist "%BACKEND_DIR%" (
    echo [ERRO] Pasta do backend nao encontrada:
    echo %BACKEND_DIR%
    echo.
    pause
    exit /b 1
)

if not exist "%FRONTEND_DIR%" (
    echo [ERRO] Pasta do frontend Flutter nao encontrada:
    echo %FRONTEND_DIR%
    echo.
    pause
    exit /b 1
)

echo [1/2] A arrancar backend Spring Boot...
start "Hotel Restaurante Backend" cmd /k "cd /d "%BACKEND_DIR%" && set DATABASE_URL=%DATABASE_URL%&& set DATABASE_USERNAME=%DATABASE_USERNAME%&& set DATABASE_PASSWORD=%DATABASE_PASSWORD%&& if exist mvnw.cmd (mvnw.cmd spring-boot:run -Dspring-boot.run.profiles=local) else (mvn spring-boot:run -Dspring-boot.run.profiles=local)"

echo.
echo A aguardar alguns segundos para o backend iniciar...
timeout /t 8 /nobreak > nul

echo [2/2] A arrancar Flutter Windows...
start "Hotel Restaurante Flutter" cmd /k "cd /d "%FRONTEND_DIR%" && flutter run -d windows --no-pub --dart-define=API_BASE_URL=http://localhost:8080"

echo.
echo =====================================================
echo   Tudo iniciado em janelas separadas.
echo =====================================================
echo.
echo Backend esperado em:
echo http://localhost:8080
echo.
echo Frontend Flutter vai consumir:
echo http://localhost:8080
echo.
pause