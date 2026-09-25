@echo off
REM ============================================================================
REM Enfos Team Survival — SametC Edition
REM Top-level validation/checks command
REM ============================================================================

setlocal enabledelayedexpansion

set "REPO_ROOT=%~dp0.."
set "GAME_DIR=%REPO_ROOT%\game"
set "ERRORS=0"
set "WARNINGS=0"

echo ============================================
echo  Enfos SametC Edition — Checks
echo ============================================
echo.

REM --- Check 1: Required files exist ---
echo [CHECK] Required files...
for %%F in (
	"game\addoninfo.txt"
	"game\scripts\vscripts\addon_game_mode.lua"
	"game\scripts\vscripts\enfos_sametc.lua"
	"game\scripts\npc\npc_abilities_custom.txt"
	"game\scripts\npc\npc_heroes_custom.txt"
	"game\scripts\npc\npc_items_custom.txt"
	"game\scripts\npc\npc_units_custom.txt"
	"game\resource\addon_english.txt"
	"game\resource\addon_turkish.txt"
	"game\resource\addon_russian.txt"
	"game\resource\addon_schinese.txt"
	"AGENTS.md"
	"docs\GAME_DESIGN_MASTER.md"
	"docs\TECHNICAL_ARCHITECTURE.md"
	"docs\IMPLEMENTATION_ROADMAP.md"
	"docs\DECISIONS_OPEN_ITEMS.md"
	"build_version.txt"
) do (
	if not exist "%REPO_ROOT%\%%~F" (
		echo   [FAIL] Missing: %%~F
		set /a ERRORS+=1
	)
)
echo   [PASS] Required files check complete.
echo.

REM --- Check 2: KV files contain opening brace ---
echo [CHECK] KV file structure...
call :check_kv "game\scripts\npc\npc_abilities_custom.txt"
call :check_kv "game\scripts\npc\npc_heroes_custom.txt"
call :check_kv "game\scripts\npc\npc_items_custom.txt"
call :check_kv "game\scripts\npc\npc_units_custom.txt"
call :check_kv "game\addoninfo.txt"
echo   [PASS] KV structure check complete.
echo.

REM --- Check 3: Localization files exist and have tokens ---
echo [CHECK] Localization files...
call :check_lang "game\resource\addon_english.txt" "English"
call :check_lang "game\resource\addon_turkish.txt" "Turkish"
call :check_lang "game\resource\addon_russian.txt" "Russian"
call :check_lang "game\resource\addon_schinese.txt" "SChinese"
echo.

REM --- Check 4: Build version ---
echo [CHECK] Build version...
set /p BUILD_VER=<"%REPO_ROOT%\build_version.txt"
echo   Version: %BUILD_VER%
echo   [PASS]
echo.

REM --- Summary ---
echo ============================================
echo  Results: %ERRORS% error(s), %WARNINGS% warning(s)
echo ============================================

if %ERRORS% GTR 0 (
	echo  FAILED
	exit /b 1
)

echo  ALL PASSED
exit /b 0

REM ============================================================================
REM Subroutines
REM ============================================================================


:check_kv
findstr /C:"{" "%REPO_ROOT%\%~1" >nul 2>&1
if errorlevel 1 (
	echo   [FAIL] %~1 missing opening brace
	set /a ERRORS+=1
)
goto :eof

:check_lang
if not exist "%REPO_ROOT%\%~1" (
	echo   [FAIL] Missing language file: %~1
	set /a ERRORS+=1
	goto :eof
)
findstr /C:"Tokens" "%REPO_ROOT%\%~1" >nul 2>&1
if errorlevel 1 (
	echo   [WARN] %~2 file missing Tokens section
	set /a WARNINGS+=1
) else (
	echo   [PASS] %~2 localization present
)
goto :eof
