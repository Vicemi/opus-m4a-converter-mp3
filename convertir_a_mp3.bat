@echo off
setlocal enabledelayedexpansion

REM Llamar a PowerShell para seleccionar las carpetas
for /f "delims=" %%i in ('powershell -noprofile -command "Add-Type -AssemblyName System.Windows.Forms; $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog; $folderBrowser.Description = 'Selecciona la carpeta donde estan los archivos a convertir'; $folderBrowser.ShowDialog() | Out-Null; $folderBrowser.SelectedPath"') do set "source_folder=%%i"

for /f "delims=" %%i in ('powershell -noprofile -command "Add-Type -AssemblyName System.Windows.Forms; $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog; $folderBrowser.Description = 'Selecciona la carpeta donde se guardaran los archivos convertidos'; $folderBrowser.ShowDialog() | Out-Null; $folderBrowser.SelectedPath"') do set "output_folder=%%i"

REM Verifica si las carpetas se seleccionaron correctamente
if "%source_folder%"=="" (
    powershell -noprofile -command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('No se selecciono ninguna carpeta de origen. El proceso se cerrara.', 'Error', 'OK', 'Error')"
    exit /b
)
if "%output_folder%"=="" (
    powershell -noprofile -command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('No se selecciono ninguna carpeta de destino. El proceso se cerrara.', 'Error', 'OK', 'Error')"
    exit /b
)

REM Verifica si la carpeta de origen está vacía
pushd "%source_folder%"
set "found_files=0"
for %%f in (*.m4a *.opus) do (
    set "found_files=1"
    goto :files_found
)

:no_files_found
powershell -noprofile -command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('La carpeta de origen no contiene archivos M4A o Opus. El proceso se cerrara.', 'Error', 'OK', 'Error')"
popd
exit /b

:files_found
popd

REM Crea la carpeta de destino si no existe
if not exist "%output_folder%" mkdir "%output_folder%"

REM Cambia al directorio de origen
cd /d "%source_folder%"

REM Convierte cada archivo M4A y Opus a MP3
for %%f in (*.m4a *.opus) do (
    echo Convirtiendo %%f a MP3...
    ffmpeg -i "%%f" -q:a 0 "%output_folder%\%%~nf.mp3"
    if !errorlevel! neq 0 (
        powershell -noprofile -command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Error al convertir %%f.', 'Error', 'OK', 'Error')"
    ) else (
        echo %%f convertido correctamente.
    )
)

powershell -noprofile -command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Conversion completada.', 'Informacion', 'OK', 'Information')"
pause
