@echo off
setlocal
cd /d "%~dp0"
title MovieMate - local dev
set LOG=%~dp0local-run.log
echo ==== MovieMate local run %date% %time% ==== > "%LOG%"

where node >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Node.js is not installed or not on PATH. >> "%LOG%"
  echo [ERROR] Node.js is not installed. Install it from https://nodejs.org and run this again.
  pause
  exit /b 1
)
for /f "delims=" %%v in ('node -v') do echo Node %%v >> "%LOG%"

rem ---- Create env files on first run ----
if not exist server\.env (
  echo Creating server\.env >> "%LOG%"
  powershell -NoProfile -Command "$s = -join ((1..48) | %% { '{0:x}' -f (Get-Random -Max 16) }); Set-Content -Path 'server\.env' -Value @('MONGO_URL=mongodb://127.0.0.1:27017/moviemate', ('SECRET_SECURITY_KEY=' + $s))"
)
if not exist .env.local (
  echo Creating .env.local >> "%LOG%"
  echo VITE_API_URL=http://localhost:5900/api> .env.local
)

rem ---- MongoDB: start service if present, otherwise install ----
sc query MongoDB >nul 2>&1
if errorlevel 1 (
  where mongod >nul 2>&1
  if errorlevel 1 (
    echo MongoDB not found - installing MongoDB Community Server via winget... >> "%LOG%"
    echo Installing MongoDB Community Server ^(approve the Windows prompt if asked^)...
    winget install -e --id MongoDB.Server --accept-package-agreements --accept-source-agreements >> "%LOG%" 2>&1
  )
)
sc query MongoDB | find "RUNNING" >nul 2>&1
if errorlevel 1 (
  echo Starting MongoDB service... >> "%LOG%"
  net start MongoDB >> "%LOG%" 2>&1
)
sc query MongoDB >> "%LOG%" 2>&1

rem ---- Install dependencies on first run ----
if not exist node_modules\vite\package.json (
  echo Installing frontend deps... >> "%LOG%"
  echo Installing frontend dependencies...
  call npm install >> "%LOG%" 2>&1
)
if not exist server\node_modules\express\package.json (
  echo Installing server deps... >> "%LOG%"
  echo Installing server dependencies...
  pushd server & call npm install >> "%LOG%" 2>&1 & popd
)
if not exist socket\node_modules\socket.io\package.json (
  echo Installing socket deps... >> "%LOG%"
  echo Installing socket dependencies...
  pushd socket & call npm install >> "%LOG%" 2>&1 & popd
)

rem ---- bcrypt native build is blocked by npm install-script policy; use pure-JS bcryptjs under the same name ----
if not exist server\node_modules\bcrypt\dist\bcrypt.js (
  echo Installing bcryptjs as bcrypt for server... >> "%LOG%"
  pushd server & call npm install "bcrypt@npm:bcryptjs@2.4.3" --no-save >> "%LOG%" 2>&1 & popd
)

rem ---- Node 25+ compatibility shim for old server deps (SlowBuffer) ----
set "NODE_OPTIONS=--require %~dp0local-dev\node-compat.cjs"

echo ==== Starting frontend (5173), API (5900), socket (15492) ==== >> "%LOG%"
echo.
echo Starting MovieMate: frontend http://localhost:5173  API http://localhost:5900  socket :15492
echo Keep this window open; close it to stop everything.
echo.
call npm start
echo Servers stopped. >> "%LOG%"
pause
