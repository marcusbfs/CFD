@echo off

REM === Variáveis ===
SET gambit_exe=C:\Fluent.Inc\ntbin\ntx86\gambit.exe
SET fechar_exceed_apos_gambit=1
SET fechar_launcher_apos_gambit=1
SET tempo_de_espera=7
SET tempo_de_espera_no_loop=3

REM #########################################

ECHO.
ECHO ###############################################
ECHO #  Data da criacao da script: 03/10/2019      #
ECHO #  Autor: Marcus Bruno - marcusbfs@gmail.com  #
ECHO #  Versao 1.0.0                               #
ECHO #  Modificado em: 13/12/2019                  #
ECHO ###############################################
ECHO.
ECHO ## Ps: O script atual so funciona se a linguagem do sistema estiver em portugues!
ECHO.


REM === Checa se o script esta sendo executado como administrador
goto check_Permissions

:check_Permissions
	ECHO O script requer privilegios de administrador para poder alterar a data.
	ECHO Verificando permissoes...

    net session >nul 2>&1
    IF NOT %errorLevel% == 0 (
        ECHO Permissoes negadas.
	ECHO.
	Echo Por favor, execute novamente como administrador.
	ECHO.
	ECHO Botao direito no script e "Executar como administrador"
        PAUSE>nul
	exit /b
    ) ELSE (
	ECHO Permissoes confirmadas.
	ECHO.
    )

REM === Checa se o caminho do Gambit é válido
IF NOT EXIST %gambit_exe% (
	ECHO O Gambit nao foi encontrado no caminho especificado ("%gambit_exe%"^)
	ECHO Por favor, altere a variavel adequada neste script
	PAUSE
	START /B NOTEPAD %0
	EXIT /B
)

REM == Variáveis temporárias
SET "diretorio_atual=%~dp0"
SET gambitdate=01-01-2007
SET gambit_cmd=%gambit_exe% -r2.4.6
SET gambit_exe_tasklist=gambit.exe
SET exceed_exe_tasklist=exceed.exe

REM === Salva data atual ===
FOR /F "skip=1" %%x in ('wmic os get localdatetime') do if not defined MyDate set MyDate=%%x
SET data_atual=%MyDate:~6,2%-%MyDate:~4,2%-%MyDate:~0,4%

REM === Muda data para %gambitdate% ===
echo Data modificada para "%gambitdate%"
date %gambitdate%
ECHO.

cd %diretorio_atual%

REM === Abre o Gambit ===
echo Abrindo Gambit...
START /B %gambit_cmd%
REM Pega processo desse Gambit
FOR /F "tokens=2" %%p in ('tasklist^|find /i "%gambit_exe_tasklist%"') DO SET gpid=%%p

:loop
FOR /F "" %%x IN ('tasklist^|find /I /C "%gambit_exe_tasklist%"') do set number_gambit_process=%%x
REM FOR /F "" %%x IN ('tasklist /FI "IMAGENAME eq %gambit_exe_tasklist%" 2>NUL | find /I /C "%gambit_exe_tasklist%"') do set number_gambit_process=%%x
ping 127.0.0.1 -n %tempo_de_espera_no_loop% > nul
if %number_gambit_process%==0 (
	ECHO Launcher do Gambit foi finalizado pelo usuario
	date %data_atual%
	echo Data retornada para "%data_atual%"
	EXIT /B
)
if %number_gambit_process% LSS 2 GOTO :loop
ECHO Gambit aberto
ECHO.
REM #########################################

ping 127.0.0.1 -n %tempo_de_espera% > nul

IF %fechar_launcher_apos_gambit%==1 (
	echo Finalizando o launcher
	TASKKILL /F /PID %gpid% 2> NUL
	ECHO.
)

REM === Retorna data atual ===
date %data_atual%
ECHO Data retornada para "%data_atual%"
ECHO.

REM === Fecha Exceed apos Gambit ser terminado, caso o usuário queira ===
IF %fechar_exceed_apos_gambit%==1 (
	ECHO Vigiando Gambit para poder finalizar Exceed com seguranca...
	:loopExceed
	FOR /F "" %%x IN ('tasklist^|find /I /C "%gambit_exe_tasklist%"') do set number_gambit_process=%%x
	ping 127.0.0.1 -n %tempo_de_espera_no_loop% > nul
	if %number_gambit_process% NEQ 0 GOTO :loopExceed

	ECHO Nenhuma instancia do Gambit sendo executada
	ECHO.
	ECHO Por favor, espere o script ser finalizado automaticamente!
	ECHO.
	ping 127.0.0.1 -n %tempo_de_espera% > nul
	TASKKILL /IM %exceed_exe_tasklist% 2> NUL
	TASKKILL /IM %exceed_exe_tasklist% 2> NUL
	ECHO Exceed finalizado
)

ECHO.
ECHO Script finalizado com sucesso
ping 127.0.0.1 -n 3 > nul
