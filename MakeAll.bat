@ECHO OFF
@call MakeRoC 1
set FAILURE=0
if "%RESULTMAKEVER%"=="1" (
  set FAILURE=1
  pause
)
@call MakeTFT 1
if "%RESULTMAKEVER%"=="1" (
  set FAILURE=1
  pause
)
@call MakeREFORGED 1
if "%RESULTMAKEVER%"=="1" (
  set FAILURE=1
  pause
)
@call MakeOptROC 1
if "%RESULTOPTVER%"=="1" (
  set FAILURE=1
  pause
)
@call MakeOptTFT 1
if "%RESULTOPTVER%"=="1" (
  set FAILURE=1
  pause
)
@call MakeOptREFORGED 1
if "%RESULTOPTVER%"=="1" (
  set FAILURE=1
  pause
)
if "%FAILURE%"=="1" (
  exit /b %FAILURE%
)
