@echo off
chcp 65001 >nul
SETLOCAL EnableDelayedExpansion
setlocal

set "tab=	"

set "script_dir=%~dp0"
set "backup_path_save=%script_dir%save"
set "source_folder=%USERPROFILE%\AppData\LocalLow\Nolla_Games_Noita\save00\"
set "config=noita_save_config.txt"

for /f "usebackq tokens=1,2 delims==" %%a in (%config%) do (
    set "%%a=%%b"
    echo %%a=%%b
)
if "%debug%"=="1" (
    pause
)


:sst
cls
echo ---Noita存档器--- 
echo 需要关闭steam云存档才能生效 
echo 游戏保存并退出后才能进行备份、还原操作 
echo 不要在游戏运行时使用此脚本 
echo 不要在备份时退出此脚本 
echo 还原时会覆盖未备份的存档 
echo 此脚本不保证存档数据完整,请保留额外备份 
echo 存储路径为此脚本路径中save文件夹 
echo github地址 
echo https://github.com/lin-lin-miao/noita_save_WindowsCMD 
echo ⭐️觉得好用点个星星⭐️ 
echo by-靈凛 


:sta
title Noita存档器(by-靈凛) 
echo --------------- 
echo 1备份,2还原,3删除,4/S启动游戏,8设置,9脚本信息,0退出 
set input=
set /p input="请选择对应数字编号:"
cls
if "%input%"=="0" (
    endlocal
    exit
)

if "%input%"=="1" goto bf
if "%input%"=="2" goto hy
if "%input%"=="3" goto de

if "%input%"=="4" goto qd
if "%input%"=="s" goto qd
if "%input%"=="S" goto qd

if "%input%"=="8" goto setting
if "%input%"=="9" goto sst
echo 请重新输入
goto sta

:setting
echo 在施工
goto sta

:bf
title Noita存档器(by-靈凛) 备份: 
rem 存档检查
call :jc_rw
call :jc_sj

call :showdir (相同的将覆盖)

set ibf=
set /p ibf="请输入数字存档号(0退出):"
if "%ibf%"=="0" goto sta
if "%ibf%"=="" (
    echo 输入不能为空,请重新输入 
    goto bf
)
set "backup_path=%script_dir%save\%ibf%\"
rd /s /q "!backup_path!"
mkdir "!backup_path!"
xcopy "%source_folder%" "!backup_path!" /E /Y /H /R
if %errorlevel%==0 (
    echo 备份文件夹路径:!backup_path! 
    echo 备份完成
    echo ---------------
    call :is_qd
) else (
    echo 备份失败:(%errorlevel%)
)
goto sta



:hy
title Noita存档器(by-靈凛) 还原: 
call :showdir
set ihy=
set /p ihy="请输入还原的存档号(0退出):"
if "%ihy%"=="0" goto sta
if "%ihy%"=="" (
    echo 输入不能为空,请重新输入 
    goto hy
)
set "backup_path=%script_dir%save\%ihy%\"
if not exist "!backup_path!" (
    echo 文件不存在,请重新输入 
    goto hy
)
rd /s /q "%source_folder%"
xcopy "!backup_path!" "%source_folder%" /E /Y /H /R
if %errorlevel%==0 (
    echo 从备份文件夹:!backup_path! 还原到文件夹:%source_folder% 
    echo 还原完成
    echo ---------------
    call :is_qd
) else (
    echo 还原失败:%errorlevel%
)

goto sta

:de
title Noita存档器(by-靈凛) 删除: 
call :showdir
set ide=
set /p ide="请输入需要删除的存档号(0退出):"
if "%ide%"=="0" goto sta
if "%ide%"=="" (
    echo 输入不能为空,请重新输入 
    goto de
)
set "backup_path=%script_dir%save\%ide%\"
rd /s /q "!backup_path!"
echo 已删除 

goto sta

:qd
title Noita存档器(by-靈凛) 启动游戏: 
set /a qdjsq=0
tasklist|find "noita.exe" >nul
if %errorlevel%==0 (
    echo 游戏正在运行
    goto sta
)
:qdz
echo 正在启动游戏...
tasklist|find "noita.exe" >nul
if %errorlevel%==0 (
    echo 启动完成
    goto sta
)
start steam://rungameid/881100
timeout /t 5 >nul
tasklist|find "noita.exe" >nul
if %errorlevel%==0 (
    echo 启动完成
    goto sta
)
set /a qdjsq+=1
echo 已尝试!qdjsq!次
if !qdjsq!==6 (
    echo 启动失败,可能是steam误判游戏正在运行,请手动停止运行
    goto sta
)
echo 游戏未启动,正在再次尝试
goto qdz

rem 函数

:is_qd
if "%自动启动%"=="1" goto qd
if "%自动启动%"=="2" (
    echo 跳过启动
    goto :eof
)
set iqd=
set /p iqd="是否直接启动游戏(1是):"
if "%iqd%"=="1" goto qd
goto :eof

:jc_rw
if not exist "%source_folder%player.xml" (
    echo 人物存档不存在
    set xzrw=
    set /p xzrw="是否继续(1是):"
    if "!xzrw!"=="1" (
        goto :eof
    )
    goto sta
)
goto :eof

:jc_sj
if not exist "%source_folder%world\.autosave_*" (
    echo 世界自动存档不存在,可能为创建了新游戏并未游玩一段时间
    set xzsj=
    set /p xzsj="是否继续(1是):"
    if "!xzsj!"=="1" (
        goto :eof
    )
    goto sta
)
goto :eof

:showdir
echo 已保存的存档号:%1
for /f "tokens=1,2,3 delims= " %%a in ('forfiles /P "%backup_path_save%" /C "cmd /c echo @fdate @ftime @fname" ^| sort /+1') do (
    set "cc=%%c"
    set "cc=!cc:"=!"
    echo !cc!%tab%%%a%tab%%%b
)
goto :eof

:setconfig
set "config_lines="
set "fand_c=0"
for /f "usebackq tokens=1,2 delims==" %%i in (%config%) do (
    echo ci %%i=%%j in %1=%2
    if "%%i"=="%1" (
        REM 替换为新的键值对
        set "line=%%i=%2"
        set "fand_c=1"
    ) else (
        set "line=%%i=%%j"
    )
    echo !line!>> %config%n
)
if "!fand_c!"=="0" (
   set "line=%1=%2"
   echo !line! >> %config%n
)
move %config%n %config%
if "%debug%"=="1" (
    pause
)
goto :eof

pause
endlocal

