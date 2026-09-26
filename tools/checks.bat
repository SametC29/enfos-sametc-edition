@echo off
setlocal
node "%~dp0checks.mjs"
exit /b %errorlevel%
