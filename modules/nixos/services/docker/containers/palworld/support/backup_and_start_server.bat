set STEAMCMDDIR="C:\steamcmd\"
set SERVERDIR="C:\steamcmd\steamapps\common\"PalServer"\"
set NETWORKDIR="\\terra\transfer\palworld-bkup\"
set APPID=2394010

set t=%date%_%time%

set d=%t:~10,4%-%t:~4,2%-%t:~7,2%-Pre
robocopy %SERVERDIR%Pal\Saved %NETWORKDIR%%d% /E

timeout /t 3 /nobreak

taskkill /im PalServer-Win64-Test-Cmd.exe

timeout /t 3 /nobreak

cd /d %STEAMCMDDIR%
steamcmd.exe +login anonymous +app_update %APPID% validate +quit

timeout /t 3 /nobreak

set d=%t:~10,4%-%t:~4,2%-%t:~7,2%-Post
robocopy %SERVERDIR%Pal\Saved %NETWORKDIR%%d% /E

timeout /t 3
cd /d %SERVERDIR%
start PalServer.exe -port=8211 -players=16 -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS