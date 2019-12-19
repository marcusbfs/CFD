@echo off
REM Coloca o diretorio padrao como o atual
@setlocal enableextensions
@cd /d "%~dp0"

REM === Variaveis ===
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
ECHO #  Versao 1.1.0                               #
ECHO #  Modificado em: 19/12/2019                  #
ECHO ###############################################
ECHO.
ECHO ## Qualquer bug ou recomendacao, nao hesite em mandar um e-mail!
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

REM === Checa se o caminho do Gambit e valido
IF NOT EXIST %gambit_exe% (
	ECHO O Gambit nao foi encontrado no caminho especificado ("%gambit_exe%"^)
	ECHO Por favor, altere a variavel adequada neste script
	PAUSE
	START /B NOTEPAD %0
	EXIT /B
)

REM == Variaveis temporarias
SET diretorio_atual=%~dp0
SET gambitdate=01-01-2007
SET gambit_cmd=%gambit_exe% -r2.4.6
SET gambit_exe_tasklist=gambit.exe
SET exceed_exe_tasklist=exceed.exe

REM === Salva data atual ===
FOR /F "skip=1" %%x in ('wmic os get localdatetime') do if not defined MyDate set MyDate=%%x
SET data_atual=%MyDate:~6,2%-%MyDate:~4,2%-%MyDate:~0,4%

REM === Muda data para %gambitdate% ===
date %gambitdate%
echo Data modificada para "%gambitdate%"
ECHO.

cd %diretorio_atual%

REM === Abre o Gambit ===
REM Abre o Launcher do Gambit
echo Abrindo Gambit...
START /B %gambit_cmd%
REM Pega processo desse Gambit
FOR /F "tokens=2" %%p in ('tasklist^|find /i "%gambit_exe_tasklist%"') DO SET launcher_pid=%%p

REM Espera o gambit de fato ser iniciado 
:loop
	FOR /F "" %%x IN ('tasklist^|find /I /C "%gambit_exe_tasklist%"') do set number_gambit_process=%%x
	REM ping 127.0.0.1 -n %tempo_de_espera_no_loop% > nul
	ping 127.0.0.1 -n 0.5 > nul
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

REM Pega processo desse Exceed
FOR /F "tokens=2" %%p in ('tasklist^|find /i "%exceed_exe_tasklist%"') DO SET exceed_pid=%%p

IF %fechar_launcher_apos_gambit%==1 (
	TASKKILL /F /PID %launcher_pid% 
	TASKKILL /F /PID %launcher_pid% 2> NUL
	ECHO Launcher do Gambit finalizado
	ECHO.
)

REM === Retorna data atual ===
date %data_atual%
ECHO Data retornada para "%data_atual%"
ECHO.

REM === Fecha Exceed apos Gambit ser terminado, caso o usu�rio queira ===
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
	TASKKILL /F /PID %exceed_pid% 
	TASKKILL /F /PID %exceed_pid% 2> NUL
	ECHO Exceed finalizado
)

ECHO.
ECHO Script finalizado com sucesso
ping 127.0.0.1 -n 3 > nul