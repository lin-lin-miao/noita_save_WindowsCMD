@echo off
chcp 65001 >nul
SETLOCAL EnableDelayedExpansion
setlocal


set "script_dir=%~dp0"
set "backup_path_save=%script_dir%save\"
set "source_folder=%USERPROFILE%\AppData\LocalLow\Nolla_Games_Noita\save00\"

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
echo by-靈凛 


:sta
title Noita存档器(by-靈凛) 
echo --------------- 
echo 1备份,2还原,3删除,4脚本信息,5/S启动游戏,0退出 
set input=
set /p input="请选择对应数字编号:"
cls
if "%input%"=="0" exit
if "%input%"=="1" goto jc_rw
if "%input%"=="2" goto hy
if "%input%"=="3" goto de
if "%input%"=="4" goto sst
if "%input%"=="5" goto qd
if "%input%"=="s" goto qd
if "%input%"=="S" goto qd
echo 请重新输入
goto sta

:bf
title Noita存档器(by-靈凛) 备份: 
echo 已保存的存档号(相同的将覆盖): 
for /d %%i in (%backup_path_save%*) do echo %%~ni
set ibf=
set /p ibf="请输入数字存档号(0退出):"
if "%ibf%"=="0" goto sta
if "%ibf%"=="" (
    echo 输入不能为空,请重新输入 
    goto bf
)
set "backup_path=%script_dir%save\%ibf%\"
rd /s /q "%backup_path%"
mkdir "%backup_path%"
xcopy "%source_folder%" "%backup_path%" /E /Y /H /R
echo 备份完成,备份文件夹路径:%backup_path% 
goto sta

:jc_rw
if not exist "%source_folder%player.xml" (
    echo 人物存档不存在
    set xzrw=
    set /p xzrw="是否继续(1是):"
    if "!xzrw!"=="1" (
        set "xzsj=1"
        goto bf
    )
    goto sta
)
goto jc_sj

:jc_sj
if not exist "%source_folder%world\.autosave_*" (
    echo 世界自动存档不存在,可能为创建了新游戏并未游玩一段时间
    set xzsj=
    set /p xzsj="是否继续(1是):"
    if "!xzsj!"=="1" (
        goto bf
    )
    set "xzsj=0"
    goto sta
)
set "xzsj=1"
goto bf

:hy
title Noita存档器(by-靈凛) 还原: 
echo 已保存的存档号: 
for /d %%i in (%backup_path_save%*) do echo %%~ni
set ihy=
set /p ihy="请输入还原的存档号(0退出):"
if "%ihy%"=="0" goto sta
if "%ihy%"=="" (
    echo 输入不能为空,请重新输入 
    goto hy
)
set "backup_path=%script_dir%save\%ihy%\"
if not exist "%backup_path%" (
    echo 文件不存在,请重新输入 
    goto hy
)
rd /s /q "%source_folder%"
xcopy "%backup_path%" "%source_folder%" /E /Y /H /R
echo 还原完成,从备份文件夹:%backup_path% 还原到文件夹:%source_folder% 
goto sta

:de
title Noita存档器(by-靈凛) 删除: 
echo 已保存的存档号: 
for /d %%i in (%backup_path_save%*) do echo %%~ni
set ide=
set /p ide="请输入需要删除的存档号(0退出):"
if "%ide%"=="0" goto sta
if "%ide%"=="" (
    echo 输入不能为空,请重新输入 
    goto de
)
set "backup_path=%script_dir%save\%ide%\"
rd /s /q "%backup_path%"
echo 已删除 
goto sta

:qd
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

endlocal
pause