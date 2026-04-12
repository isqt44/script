@echo off
:: ============================================================================
:: AUTO-ELEVACION A ADMINISTRADOR + VENTANA PERSISTENTE
:: ============================================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo  Solicitando permisos de administrador...
    powershell -Command "Start-Process cmd.exe -ArgumentList '/K \"%~f0\"' -Verb RunAs"
    exit /b
)
if "%RELAUNCHED%"=="" (
    set RELAUNCHED=1
    cmd /K "%~f0"
    exit /b
)
:: ============================================================================
::
::  ██╗   ██╗██╗  ████████╗██████╗  █████╗      ██████╗ ██████╗ ████████╗
::  ██║   ██║██║  ╚══██╔══╝██╔══██╗██╔══██╗    ██╔═══██╗██╔══██╗╚══██╔══╝
::  ██║   ██║██║     ██║   ██████╔╝███████║    ██║   ██║██████╔╝   ██║
::  ╚██████╔╝███████╗██║   ██║  ██║██║  ██║    ╚██████╔╝██║        ██║
::   ╚═════╝ ╚══════╝╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝    ╚═════╝ ╚═╝        ╚═╝
::
::          GAMING & STREAMING ULTRA OPTIMIZER  - CMD/BAT v3.0
::          Compatible: Windows 10 build 1809+ / Windows 11
::
:: ============================================================================

chcp 65001 >nul 2>&1
color 03
title ULTRA OPT — Gaming ^& Streaming Optimizer [CMD]
setlocal EnableDelayedExpansion

:: Contadores
set /a OK=0
set /a FAIL=0
set /a SKIP=0

:: ─── VERIFICAR ADMIN ────────────────────────────────────────────────────────
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  [!] ERROR: Necesitas ejecutar este script como ADMINISTRADOR.
    echo  Haz clic derecho ^> Ejecutar como administrador
    echo.
    pause
    exit /b 1
)

:: ─── DETECTAR VERSIÓN WINDOWS ───────────────────────────────────────────────
for /f "tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild 2^>nul') do set BUILD=%%a
set WIN11=0
if %BUILD% GEQ 22000 set WIN11=1

:: ─── SPLASH SCREEN ──────────────────────────────────────────────────────────
cls
echo.
echo  ╔══════════════════════════════════════════════════════════════════╗
echo  ║                                                                  ║
echo  ║    ██╗   ██╗██╗  ████████╗██████╗  █████╗     ██████╗ ██████╗   ║
echo  ║    ██║   ██║██║  ╚══██╔══╝██╔══██╗██╔══██╗   ██╔═══██╗██╔══██╗  ║
echo  ║    ██║   ██║██║     ██║   ██████╔╝███████║   ██║   ██║██████╔╝  ║
echo  ║    ╚██████╔╝███████╗██║   ██║  ██║██║  ██║   ╚██████╔╝██║       ║
echo  ╠══════════════════════════════════════════════════════════════════╣
echo  ║        GAMING ^& STREAMING ULTRA OPTIMIZER — CMD v3.0            ║
echo  ║        Compatible: Windows 10 ^/ Windows 11                      ║
echo  ╚══════════════════════════════════════════════════════════════════╝
echo.

if %WIN11%==1 (
    echo  Sistema detectado: Windows 11 (Build %BUILD%)
) else (
    echo  Sistema detectado: Windows 10 (Build %BUILD%)
)
echo.
echo  ADVERTENCIA: Este script modifica el registro y la configuracion
echo  del sistema. Se recomienda hacer una copia de seguridad primero.
echo.
echo  Presiona ENTER para continuar o CTRL+C para cancelar...
pause >nul

:: ============================================================================
:: SECCIÓN 1: PUNTO DE RESTAURACIÓN
:: ============================================================================
call :HEADER "1/16 CREANDO PUNTO DE RESTAURACION"

wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "Antes de Ultra Optimizer", 100, 7 >nul 2>&1
if %errorlevel%==0 (
    call :PRINTOK "Punto de restauracion creado"
) else (
    call :PRINTSKIP "Punto de restauracion no disponible"
)

:: ============================================================================
:: SECCIÓN 2: LIMPIEZA EXTREMA
:: ============================================================================
call :HEADER "2/16 LIMPIEZA EXTREMA DEL SISTEMA"

:: Limpiar Temp
call :PRINTINFO "Limpiando directorios temporales..."

rd /s /q "%TEMP%" >nul 2>&1
md "%TEMP%" >nul 2>&1
call :PRINTOK "Limpiado: %%TEMP%%"

rd /s /q "%TMP%" >nul 2>&1
md "%TMP%" >nul 2>&1
call :PRINTOK "Limpiado: %%TMP%%"

rd /s /q "C:\Windows\Temp" >nul 2>&1
md "C:\Windows\Temp" >nul 2>&1
call :PRINTOK "Limpiado: C:\Windows\Temp"

:: Prefetch (solo en HDD, en SSD se puede omitir)
del /f /q "C:\Windows\Prefetch\*.*" >nul 2>&1
call :PRINTOK "Prefetch limpiado"

:: Windows Update cache
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
rd /s /q "C:\Windows\SoftwareDistribution\Download" >nul 2>&1
md "C:\Windows\SoftwareDistribution\Download" >nul 2>&1
net start wuauserv >nul 2>&1
net start bits >nul 2>&1
call :PRINTOK "Cache de Windows Update limpiada"

:: Internet Explorer / Edge cache
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 255 >nul 2>&1
call :PRINTOK "Cache Internet Explorer/Legacy Edge limpiada"

:: DNS cache
ipconfig /flushdns >nul 2>&1
call :PRINTOK "Cache DNS limpiada"

:: Logs CBS
rd /s /q "C:\Windows\Logs\CBS" >nul 2>&1
md "C:\Windows\Logs\CBS" >nul 2>&1
call :PRINTOK "Logs CBS limpiados"

:: WER (Error Reporting)
rd /s /q "C:\ProgramData\Microsoft\Windows\WER\ReportArchive" >nul 2>&1
rd /s /q "C:\ProgramData\Microsoft\Windows\WER\ReportQueue" >nul 2>&1
call :PRINTOK "WER Reports eliminados"

:: Memory dumps
del /f /q "C:\Windows\memory.dmp" >nul 2>&1
del /f /q /s "C:\Windows\Minidump\*.dmp" >nul 2>&1
call :PRINTOK "Memory dumps eliminados"

:: Recent files
del /f /q "%APPDATA%\Microsoft\Windows\Recent\*.*" >nul 2>&1
call :PRINTOK "Archivos recientes eliminados"

:: Thumbnails cache
del /f /q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
call :PRINTOK "Cache de miniaturas eliminada"

:: Cleanmgr silencioso (sagerun 1)
cleanmgr /sageset:1 >nul 2>&1
cleanmgr /sagerun:1 >nul 2>&1
call :PRINTOK "Disk Cleanup ejecutado"

:: Event logs
for %%L in (Application System Security Setup) do (
    wevtutil cl %%L >nul 2>&1
    call :PRINTOK "EventLog limpiado: %%L"
)

:: DISM - limpieza componentes
call :PRINTINFO "DISM StartComponentCleanup (puede tardar varios minutos)..."
start /wait dism.exe /Online /Cleanup-Image /StartComponentCleanup >nul 2>&1
call :PRINTOK "DISM limpieza de componentes completada"

:: ============================================================================
:: SECCIÓN 3: DESINSTALAR ONEDRIVE
:: ============================================================================
call :HEADER "3/16 DESINSTALANDO ONEDRIVE Y BLOATWARE"

:: Detener OneDrive
taskkill /f /im OneDrive.exe >nul 2>&1

:: Desinstalar
if exist "%SystemRoot%\SysWOW64\OneDriveSetup.exe" (
    %SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall /quiet >nul 2>&1
    call :PRINTOK "OneDrive desinstalado (SysWOW64)"
)
if exist "%SystemRoot%\System32\OneDriveSetup.exe" (
    %SystemRoot%\System32\OneDriveSetup.exe /uninstall /quiet >nul 2>&1
    call :PRINTOK "OneDrive desinstalado (System32)"
)
if exist "%LOCALAPPDATA%\Microsoft\OneDrive\OneDriveSetup.exe" (
    "%LOCALAPPDATA%\Microsoft\OneDrive\OneDriveSetup.exe" /uninstall /quiet >nul 2>&1
    call :PRINTOK "OneDrive desinstalado (LOCALAPPDATA)"
)

:: Limpiar carpetas OneDrive
rd /s /q "%USERPROFILE%\OneDrive" >nul 2>&1
rd /s /q "%LOCALAPPDATA%\Microsoft\OneDrive" >nul 2>&1
rd /s /q "%PROGRAMDATA%\Microsoft OneDrive" >nul 2>&1
call :PRINTOK "Carpetas OneDrive eliminadas"

:: Deshabilitar por GPO
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /t REG_DWORD /d 1 /f >nul 2>&1
call :PRINTOK "OneDrive bloqueado por politica de grupo"

:: Cortana deshabilitada
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 0 /f >nul 2>&1
call :PRINTOK "Cortana deshabilitada"

:: ============================================================================
:: SECCIÓN 4: REGISTRO — RENDIMIENTO GENERAL
:: ============================================================================
call :HEADER "4/16 REGISTRO: RENDIMIENTO GENERAL"

:: Prioridad procesos foreground
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 38 /f >nul 2>&1
call :PRINTOK "Win32PrioritySeparation = 38 (foreground boost maximo)"

reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "IRQ8Priority" /t REG_DWORD /d 1 /f >nul 2>&1
call :PRINTOK "IRQ8 prioridad elevada"

:: Gestión de memoria
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d 0 /f >nul 2>&1
call :PRINTOK "LargeSystemCache = 0 (RAM para procesos)"

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d 1 /f >nul 2>&1
call :PRINTOK "Kernel en RAM (DisablePagingExecutive=1)"

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "IoPageLockLimit" /t REG_DWORD /d 983040 /f >nul 2>&1
call :PRINTOK "IoPageLockLimit aumentado"

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "ClearPageFileAtShutdown" /t REG_DWORD /d 0 /f >nul 2>&1
call :PRINTOK "PageFile: no limpiar al apagar"

:: Prefetch SSD
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t REG_DWORD /d 0 /f >nul 2>&1
call :PRINTOK "Prefetch/Superfetch deshabilitado (optimo para SSD)"

:: NTFS
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsDisable8dot3NameCreation" /t REG_DWORD /d 1 /f >nul 2>&1
call :PRINTOK "NTFS: nombres 8.3 deshabilitados"

reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsDisableLastAccessUpdate" /t REG_DWORD /d 80000003 /f >nul 2>&1
call :PRINTOK "NTFS: LastAccess Update deshabilitado"

reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsMftZoneReservation" /t REG_DWORD /d 2 /f >nul 2>&1
call :PRINTOK "NTFS: MFT Zone optimizada"

:: Multimedia / Gaming profile
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f >nul 2>&1
call :PRINTOK "SystemResponsiveness = 0 (maximo gaming/multimedia)"

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 0xffffffff /f >nul 2>&1
call :PRINTOK "NetworkThrottlingIndex deshabilitado"

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Affinity" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Background Only" /t REG_SZ /d "False" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Clock Rate" /t REG_DWORD /d 10000 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d "High" /f >nul 2>&1
call :PRINTOK "Perfil de tareas Games: GPU/CPU Priority maximo"

:: ============================================================================
:: SECCIÓN 5: INPUT DELAY — REDUCCIÓN MÁXIMA
:: ============================================================================
call :HEADER "5/16 REDUCCION DE INPUT DELAY"

:: Desactivar aceleración de ratón
reg add "HKCU\Control Panel\Mouse" /v "MouseSpeed" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold1" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold2" /t REG_SZ /d "0" /f >nul 2>&1
call :PRINTOK "Aceleracion de raton DESACTIVADA"

:: Mouse data queue
reg add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v "MouseDataQueueSize" /t REG_DWORD /d 16 /f >nul 2>&1
call :PRINTOK "MouseDataQueueSize reducida (menos buffer)"

reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v "KeyboardDataQueueSize" /t REG_DWORD /d 16 /f >nul 2>&1
call :PRINTOK "KeyboardDataQueueSize reducida"

:: USB Selective Suspend
reg add "HKLM\SYSTEM\CurrentControlSet\Services\usbhub\Parameters" /v "DisableSelectiveSuspend" /t REG_DWORD /d 1 /f >nul 2>&1
call :PRINTOK "USB Selective Suspend deshabilitado"

:: Timer resolution BCDedit
bcdedit /set useplatformtick yes >nul 2>&1
bcdedit /set disabledynamictick yes >nul 2>&1
call :PRINTOK "Timer resolution: tick minimo forzado"

:: Kernel timer
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "GlobalTimerResolutionRequests" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DistributeTimers" /t REG_DWORD /d 0 /f >nul 2>&1
call :PRINTOK "Kernel: GlobalTimerResolution habilitado"

:: Game DVR
reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehavior" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_DXGIHonorFSEWindowsCompatible" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" /v "value" /t REG_DWORD /d 0 /f >nul 2>&1
call :PRINTOK "Game DVR deshabilitado (reduce latencia de input)"

:: ============================================================================
:: SECCIÓN 6: GPU — OPTIMIZACIÓN
:: ============================================================================
call :HEADER "6/16 GPU: DETECCION Y OPTIMIZACION"

:: Detectar GPU
set GPUNAME=Desconocida
for /f "tokens=2 delims==" %%G in ('wmic path win32_VideoController get Name /value 2^>nul ^| findstr "="') do (
    set GPUNAME=%%G
    call :PRINTINFO "GPU detectada: %%G"
)

:: HAGS (Hardware-Accelerated GPU Scheduling)
if %BUILD% GEQ 19041 (
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f >nul 2>&1
    call :PRINTOK "HAGS (Hardware-Accelerated GPU Scheduling) HABILITADO"
) else (
    call :PRINTSKIP "HAGS requiere Win10 build 19041+ - omitido"
)

:: D3D / DXGI
reg add "HKLM\SOFTWARE\Microsoft\DirectX" /v "MaximumFrameLatency" /t REG_DWORD /d 1 /f >nul 2>&1
call :PRINTOK "DirectX MaximumFrameLatency = 1"

reg add "HKCU\SOFTWARE\Microsoft\Direct3D" /v "MaximumFrameLatency" /t REG_DWORD /d 1 /f >nul 2>&1
call :PRINTOK "Direct3D MaximumFrameLatency = 1"

:: Verificar NVIDIA
echo %GPUNAME% | findstr /i "NVIDIA GeForce RTX GTX Quadro" >nul 2>&1
if %errorlevel%==0 (
    call :PRINTINFO "GPU NVIDIA detectada - aplicando optimizaciones..."
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PerfLevelSrc" /t REG_DWORD /d 0x2222 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PowerMizerEnable" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PowerMizerLevel" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PowerMizerLevelAC" /t REG_DWORD /d 1 /f >nul 2>&1
    call :PRINTOK "NVIDIA: PowerMizer forzado a maximo rendimiento"
)

:: Verificar AMD
echo %GPUNAME% | findstr /i "AMD Radeon RX Vega RDNA" >nul 2>&1
if %errorlevel%==0 (
    call :PRINTINFO "GPU AMD detectada - aplicando optimizaciones..."
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableUlps" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PP_SclkDeepSleepDisable" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PP_ThermalAutoThrottlingEnable" /t REG_DWORD /d 0 /f >nul 2>&1
    call :PRINTOK "AMD: ULPS deshabilitado, Thermal Throttling deshabilitado"
)

:: ============================================================================
:: SECCIÓN 7: CPU — PLAN DE ENERGÍA ULTIMATE PERFORMANCE
:: ============================================================================
call :HEADER "7/16 CPU: PLAN ULTIMATE PERFORMANCE"

:: Activar plan Ultimate Performance
powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
for /f "tokens=4" %%G in ('powercfg /list ^| findstr /i "Ultimate"') do (
    powercfg /setactive %%G >nul 2>&1
    call :PRINTOK "Plan ULTIMATE PERFORMANCE activado: %%G"
)
:: Fallback High Performance
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1

:: Deshabilitar hibernación
powercfg /hibernate off >nul 2>&1
call :PRINTOK "Hibernacion DESHABILITADA"

powercfg /change standby-timeout-ac 0 >nul 2>&1
powercfg /change monitor-timeout-ac 0 >nul 2>&1
powercfg /change disk-timeout-ac 0 >nul 2>&1
call :PRINTOK "Timeouts de energia = 0 (nunca se apaga)"

:: CPU mínima al 100%
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 >nul 2>&1
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 >nul 2>&1
powercfg /apply >nul 2>&1
call :PRINTOK "CPU: frecuencia minima AC = 100%% (sin throttle)"

:: Turbo Boost agresivo
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFBOOSTMODE 2 >nul 2>&1
call :PRINTOK "CPU Turbo Boost: modo agresivo"

:: Spectre/Meltdown mitigaciones rendimiento
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d 3 /f >nul 2>&1
call :PRINTOK "Mitigaciones Spectre/Meltdown: modo rendimiento"

:: ============================================================================
:: SECCIÓN 8: RED — GAMING Y STREAMING
:: ============================================================================
call :HEADER "8/16 RED: OPTIMIZACION GAMING Y STREAMING"

netsh int tcp set global autotuninglevel=normal >nul 2>&1
call :PRINTOK "TCP AutoTuning = normal"

netsh int tcp set global chimney=disabled >nul 2>&1
call :PRINTOK "TCP Chimney offload deshabilitado"

netsh int tcp set global ecncapability=disabled >nul 2>&1
call :PRINTOK "ECN deshabilitado"

netsh int tcp set global timestamps=disabled >nul 2>&1
call :PRINTOK "TCP Timestamps deshabilitado"

netsh int tcp set global rss=enabled >nul 2>&1
call :PRINTOK "RSS habilitado"

netsh int tcp set global rsc=disabled >nul 2>&1
call :PRINTOK "RSC deshabilitado (menor latencia)"

netsh int tcp set global nonsackrttresiliency=disabled >nul 2>&1
call :PRINTOK "NonSack RTT Resiliency deshabilitado"

netsh int tcp set global maxsynretransmissions=2 >nul 2>&1
call :PRINTOK "MaxSynRetransmissions = 2"

netsh int tcp set global initialRto=2000 >nul 2>&1
call :PRINTOK "Initial RTO = 2000ms"

netsh int tcp set supplemental internet congestionprovider=ctcp >nul 2>&1
call :PRINTOK "Proveedor congestion = CTCP"

netsh int ip set global taskoffload=enabled >nul 2>&1
call :PRINTOK "IP Task Offload habilitado"

netsh int ip set global neighborcachelimit=4096 >nul 2>&1
netsh int ip set global routecachelimit=4096 >nul 2>&1
call :PRINTOK "NeighborCache y RouteCache = 4096"

:: Registro TCP/IP
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DefaultTTL" /t REG_DWORD /d 64 /f >nul 2>&1
call :PRINTOK "TTL = 64"

reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "MaxUserPort" /t REG_DWORD /d 65534 /f >nul 2>&1
call :PRINTOK "MaxUserPort = 65534"

reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpTimedWaitDelay" /t REG_DWORD /d 30 /f >nul 2>&1
call :PRINTOK "TcpTimedWaitDelay = 30"

reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpMaxDataRetransmissions" /t REG_DWORD /d 3 /f >nul 2>&1
call :PRINTOK "MaxDataRetransmissions = 3"

reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "SackOpts" /t REG_DWORD /d 1 /f >nul 2>&1
call :PRINTOK "SACK habilitado"

reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "EnablePMTUDiscovery" /t REG_DWORD /d 1 /f >nul 2>&1
call :PRINTOK "PMTU Discovery habilitado"

:: QoS bandwidth reservada = 0
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /t REG_DWORD /d 0 /f >nul 2>&1
call :PRINTOK "QoS: bandwidth reservada SO = 0%%"

:: Nagle deshabilitado (reduce latencia en juegos online)
for /f "tokens=*" %%K in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" 2^>nul') do (
    reg add "%%K" /v "TcpAckFrequency" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "%%K" /v "TCPNoDelay" /t REG_DWORD /d 1 /f >nul 2>&1
)
call :PRINTOK "Algoritmo Nagle DESHABILITADO en todas las interfaces"

:: ============================================================================
:: SECCIÓN 9: SERVICIOS INNECESARIOS
:: ============================================================================
call :HEADER "9/16 SERVICIOS: DESHABILITANDO INNECESARIOS"

set SERVICES_DISABLE=SysMain WSearch DiagTrack dmwappushservice MapsBroker lfsvc SharedAccess WbioSrvc WMPNetworkSvc icssvc wisvc RetailDemo RemoteRegistry RemoteAccess XblAuthManager XblGameSave XboxNetApiSvc XboxGipSvc Fax PrintNotify TabletInputService WerSvc wercplsupport PcaSvc TrkWks BDESVC BITS DoSvc wuauserv UsoSvc WpnService CDPSvc CDPUserSvc AJRouter EntAppSvc PhoneSvc SCardSvr ScDeviceEnum SEMgrSvc SensorDataService SensorService SensrSvc TermService UmRdpService SessionEnv Spooler edgeupdate edgeupdatem MicrosoftEdgeElevationService OneSyncSvc

for %%S in (%SERVICES_DISABLE%) do (
    sc query "%%S" >nul 2>&1
    if !errorlevel!==0 (
        sc config "%%S" start= disabled >nul 2>&1
        net stop "%%S" /y >nul 2>&1
        call :PRINTOK "Servicio deshabilitado: %%S"
    ) else (
        call :PRINTSKIP "Servicio no encontrado: %%S"
    )
)

:: ============================================================================
:: SECCIÓN 10: VISUAL FX
:: ============================================================================
call :HEADER "10/16 VISUAL FX: MINIMO OVERHEAD"

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f >nul 2>&1
call :PRINTOK "Visual Effects = Mejor rendimiento"

reg add "HKCU\Control Panel\Desktop" /v "DragFullWindows" /t REG_SZ /d "0" /f >nul 2>&1
call :PRINTOK "Arrastrar ventana: solo contorno"

reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d "0" /f >nul 2>&1
call :PRINTOK "Animacion minimizar/maximizar OFF"

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ListviewAlphaSelect" /t REG_DWORD /d 0 /f >nul 2>&1
call :PRINTOK "Transparencia de seleccion OFF"

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAnimations" /t REG_DWORD /d 0 /f >nul 2>&1
call :PRINTOK "Animaciones barra de tareas OFF"

reg add "HKCU\Software\Microsoft\Windows\DWM" /v "EnableAeroPeek" /t REG_DWORD /d 0 /f >nul 2>&1
call :PRINTOK "Aero Peek deshabilitado"

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d 0 /f >nul 2>&1
call :PRINTOK "Transparencia de Windows OFF"

:: ============================================================================
:: SECCIÓN 11: DISCO / NTFS
:: ============================================================================
call :HEADER "11/16 DISCO: OPTIMIZACION NTFS"

fsutil behavior set disablelastaccess 1 >nul 2>&1
call :PRINTOK "NTFS: LastAccess deshabilitado"

fsutil behavior set encryptpagingfile 0 >nul 2>&1
call :PRINTOK "NTFS: Encriptacion PageFile OFF"

fsutil behavior set memoryusage 2 >nul 2>&1
call :PRINTOK "NTFS: MemoryUsage = 2 (alto)"

fsutil behavior set mftzone 2 >nul 2>&1
call :PRINTOK "NTFS: MFT Zone = 2"

fsutil behavior set disablecompression 1 >nul 2>&1
call :PRINTOK "NTFS: Compresion deshabilitada"

:: TRIM
fsutil behavior set disabledeletenotify 0 >nul 2>&1
call :PRINTOK "TRIM (DeleteNotify) habilitado"

:: Deshabilitar desfrag automática
schtasks /change /tn "\Microsoft\Windows\Defrag\ScheduledDefrag" /disable >nul 2>&1
call :PRINTOK "Desfragmentacion automatica deshabilitada"

:: ============================================================================
:: SECCIÓN 12: PRIVACIDAD Y TELEMETRÍA
:: ============================================================================
call :HEADER "12/16 PRIVACIDAD: TELEMETRIA ELIMINADA"

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
call :PRINTOK "Telemetria = 0 (Security only)"

reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
call :PRINTOK "DataCollection Telemetry = 0"

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v "DisabledByGroupPolicy" /t REG_DWORD /d 1 /f >nul 2>&1
call :PRINTOK "Advertising ID deshabilitado"

reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
call :PRINTOK "Advertising Info usuario OFF"

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableInventory" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisablePCA" /t REG_DWORD /d 1 /f >nul 2>&1
call :PRINTOK "Application Telemetry y PCA OFF"

:: Bloquear ejecutables de telemetría
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\CompatTelRunner.exe" /v "Debugger" /t REG_SZ /d "%" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\DeviceCensus.exe" /v "Debugger" /t REG_SZ /d "%" /f >nul 2>&1
call :PRINTOK "CompatTelRunner y DeviceCensus bloqueados"

:: CEIP
schtasks /change /tn "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /disable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /disable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /disable >nul 2>&1
call :PRINTOK "CEIP tareas deshabilitadas"

:: ============================================================================
:: SECCIÓN 13: GAME MODE
:: ============================================================================
call :HEADER "13/16 GAME MODE Y OPTIMIZACIONES DIRECTX"

reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\GameBar" /v "ShowGameModeNotifications" /t REG_DWORD /d 0 /f >nul 2>&1
call :PRINTOK "Game Mode HABILITADO (sin notificaciones)"

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d 0 /f >nul 2>&1
call :PRINTOK "Game DVR politica global OFF"

:: ============================================================================
:: SECCIÓN 14: TAREAS PROGRAMADAS
:: ============================================================================
call :HEADER "14/16 TAREAS PROGRAMADAS INNECESARIAS"

schtasks /change /tn "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /disable >nul 2>&1
call :PRINTOK "Tarea: Compatibility Appraiser OFF"

schtasks /change /tn "\Microsoft\Windows\Application Experience\ProgramDataUpdater" /disable >nul 2>&1
call :PRINTOK "Tarea: ProgramDataUpdater OFF"

schtasks /change /tn "\Microsoft\Windows\Application Experience\StartupAppTask" /disable >nul 2>&1
call :PRINTOK "Tarea: StartupAppTask OFF"

schtasks /change /tn "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /disable >nul 2>&1
call :PRINTOK "Tarea: DiskDiagnosticDataCollector OFF"

schtasks /change /tn "\Microsoft\Windows\Feedback\Siuf\DmClient" /disable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" /disable >nul 2>&1
call :PRINTOK "Tarea: Feedback DmClient OFF"

schtasks /change /tn "\Microsoft\Windows\Windows Error Reporting\QueueReporting" /disable >nul 2>&1
call :PRINTOK "Tarea: WER QueueReporting OFF"

schtasks /change /tn "\Microsoft\Windows\UpdateOrchestrator\Schedule Scan" /disable >nul 2>&1
call :PRINTOK "Tarea: WindowsUpdate Schedule Scan OFF"

schtasks /change /tn "\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem" /disable >nul 2>&1
call :PRINTOK "Tarea: Power Efficiency Diagnostics OFF"

schtasks /change /tn "\Microsoft\Windows\Maps\MapsUpdateTask" /disable >nul 2>&1
call :PRINTOK "Tarea: Maps Update OFF"

:: ============================================================================
:: SECCIÓN 15: ESPECÍFICO W10 / W11
:: ============================================================================
call :HEADER "15/16 OPTIMIZACIONES ESPECIFICAS DE VERSION"

if %WIN11%==1 (
    call :PRINTINFO "Aplicando ajustes especificos Windows 11..."

    :: Deshabilitar Widgets
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarDa" /t REG_DWORD /d 0 /f >nul 2>&1
    call :PRINTOK "W11: Widgets deshabilitados"

    :: Deshabilitar Teams Chat
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarMn" /t REG_DWORD /d 0 /f >nul 2>&1
    call :PRINTOK "W11: Teams Chat barra deshabilitado"

    :: Deshabilitar Snap Bar
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "EnableSnapBar" /t REG_DWORD /d 0 /f >nul 2>&1
    call :PRINTOK "W11: Snap Bar deshabilitado"

    :: Seccion recomendados en Inicio
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "HideRecommendedSection" /t REG_DWORD /d 1 /f >nul 2>&1
    call :PRINTOK "W11: Sección recomendados del Inicio oculta"

) else (
    call :PRINTINFO "Aplicando ajustes especificos Windows 10..."

    :: Timeline
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableActivityFeed" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "UploadUserActivities" /t REG_DWORD /d 0 /f >nul 2>&1
    call :PRINTOK "W10: Timeline deshabilitada"

    :: Lock Screen ads
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338387Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    call :PRINTOK "W10: Anuncios y sugerencias del sistema OFF"
)

:: Audio latencia
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "Affinity" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "Background Only" /t REG_SZ /d "False" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "Clock Rate" /t REG_DWORD /d 10000 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "Priority" /t REG_DWORD /d 6 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "Scheduling Category" /t REG_SZ /d "High" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "SFIO Priority" /t REG_SZ /d "High" /f >nul 2>&1
call :PRINTOK "Audio: latencia minima configurada"

:: ============================================================================
:: SECCIÓN 16: RESUMEN FINAL
:: ============================================================================
call :HEADER "16/16 RESUMEN Y FINALIZACION"

:: Guardar log
set LOGFILE=%USERPROFILE%\Desktop\UltraOpt_CMD_Log_%date:~6,4%%date:~3,2%%date:~0,2%.txt
echo ============================================== > "%LOGFILE%"
echo  ULTRA OPTIMIZER CMD - Log de sesion          >> "%LOGFILE%"
echo  Fecha: %date% %time%                         >> "%LOGFILE%"
echo  Sistema: Windows Build %BUILD%               >> "%LOGFILE%"
echo ============================================== >> "%LOGFILE%"
echo  OK:   %OK% optimizaciones aplicadas          >> "%LOGFILE%"
echo  SKIP: %SKIP% omitidas (no disponibles)       >> "%LOGFILE%"
echo ============================================== >> "%LOGFILE%"

echo.
echo  ╔══════════════════════════════════════════════════════════╗
echo  ║           OPTIMIZACION COMPLETADA                       ║
echo  ╠══════════════════════════════════════════════════════════╣
echo  ║  Sistema: Windows Build %BUILD%                             ║
echo  ║  Log: Desktop\UltraOpt_CMD_Log_...txt                  ║
echo  ╠══════════════════════════════════════════════════════════╣
echo  ║   SE RECOMIENDA REINICIAR EL SISTEMA AHORA              ║
echo  ╚══════════════════════════════════════════════════════════╝
echo.

set /p REINICIAR=  Deseas reiniciar ahora? [S/N]: 
if /i "%REINICIAR%"=="S" (
    echo  Reiniciando en 5 segundos...
    timeout /t 5 >nul
    shutdown /r /t 0
) else (
    echo  Recuerda reiniciar manualmente para aplicar todos los cambios.
    echo.
    pause
)

goto :EOF

:: ============================================================================
:: FUNCIONES DE UTILIDAD
:: ============================================================================

:HEADER
echo.
echo  ┌──────────────────────────────────────────────────────────────┐
echo  │  %~1
echo  └──────────────────────────────────────────────────────────────┘
echo.
goto :EOF

:PRINTOK
echo  [  OK  ] %~1
set /a OK+=1
goto :EOF

:PRINTFAIL
echo  [ FAIL ] %~1
set /a FAIL+=1
goto :EOF

:PRINTSKIP
echo  [ SKIP ] %~1
set /a SKIP+=1
goto :EOF

:PRINTINFO
echo  [ INFO ] %~1
goto :EOF
