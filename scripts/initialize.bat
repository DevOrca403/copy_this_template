:: Author : Yoonha Hwang (DevOrca403)

@echo off
setlocal enabledelayedexpansion

:: Check conda installed

set CandidatePaths=( ^
	"%USERPROFILE%\Anaconda3\Scripts\conda.exe" ^
	"%USERPROFILE%\anaconda3\Scripts\conda.exe" ^
)

for %%i in %CandidatePaths% do (
	if exist %%i (
		set "CONDA_PATH=%%i"
	)
)

if not defined CONDA_PATH (
	echo [EXPORT] Conda is not installed. Please install conda first.
	exit /b 1
)

for %%I in (%CONDA_PATH%) do (
	set "SCRIPTS_PATH=%%~dpI"
)
call "%SCRIPTS_PATH%/activate.bat"

:: Create conda environment

set /p projectName=[INITIALIZE] Enter project name:
if "%projectName%"=="" (
	echo [INITIALIZE] Project name is empty. Please enter project name.
	exit /b 1
)

set pythonVersion=3.8
set /p pythonVersion=[INITIALIZE] Enter python version (default: 3.8):

echo [INITIALIZE] Creating conda environment...
call conda create -n %projectName% python=%pythonVersion% -y
if %errorlevel% neq 0 (
	echo [INITIALIZE] Failed to create conda environment.
	exit /b 1
)

echo [INITIALIZE] Conda environment created successfully.

:: Create environment.yml

echo [INITIALIZE] Exporting conda environment...`
call activate %projectName%
if %errorlevel% neq 0 (
	echo [INITIALIZE] Failed to activate conda environment.
	exit /b 1
)

call conda env export --no-builds --from-history > environment.yml
if %errorlevel% neq 0 (
	echo [INITIALIZE] Failed to export conda environment.
	goto :EXIT_CONDA_ENVIRONMENT
)

echo [INITIALIZE] Conda environment exported successfully.

:: Create scripts

echo [INITIALIZE] Creating scripts...

> "./scripts/export.bat" (
    for /f "usebackq delims=" %%a in ("./scripts/export.txt") do (
        set "line=%%a"
        set "line=!line:(SetProjectName)=set projectName=%projectName%!"
        echo !line!
    )
)

> "./scripts/install.bat" (
    for /f "usebackq delims=" %%a in ("./scripts/install.txt") do (
        set "line=%%a"
        set "line=!line:(SetProjectName)=set projectName=%projectName%!"
        echo !line!
    )
)

:: Deactivate conda environment

:EXIT_CONDA_ENVIRONMENT
call conda deactivate

endlocal
@echo on

