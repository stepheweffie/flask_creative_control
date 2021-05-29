@echo off
rem Do not remove this line. File tag: windows_launch-APV-7.1.2.
 
if "%OS%" == "Windows_NT" setlocal

rem ====================================================================
rem === CHECK THIS OUT
rem ====================================================================
rem JAVA_HOME must point to your Java Development Kit installation
set JAVA_HOME=C:\Program Files\Java\jdk-16.0.1

rem =======================================================================
rem === CHECK THIS OUT
rem =======================================================================
rem JAVA_OPTS should contain any Java Virtual Machine options. Here are some tips:
rem 1) Always use the "-server" option, when available.
rem 2) Give more RAM to the server process, especially with heavy traffic, by specifying a min and max "heap"
rem    E.g.: If you have 4 GB and the box is dedicated to Lightstreamer, you might set 1 GB min heap and 3 GB max
rem    heap with these options: "-Xms1G -Xmx3G"
rem 3) Choose a better "garbage collector" if you want to reduce latency. This should not be needed since Java 9,
rem    but if you are using Java 8 (apart from early versions) we suggest you enforcing:
rem    "-XX:+UseG1GC". For previous versions, an option that often gives good results is:
rem    "-XX:+UseConcMarkSweepGC". Many other tuning options are available (please see Oracle docs).
rem 4) Configure the garbage collector in such a way as to prevent long pauses. If your Java installation
rem    offers a "pauseless" collector, we encourage you to use it. Otherwise, choose the maximum pause
rem    to be enforced, based on your latency and throughput requirements, but consider anyway that GC pauses
rem    cause the connection to stay idle and pauses longer than 4 or 5 seconds may cause the clients
rem    to timeout and reconnect.
set JAVA_OPTS=-server -XX:MaxGCPauseMillis=1000
 
rem Options needed by third party libraries:
set JAVA_OPTS=%JAVA_OPTS% -Dcom.sun.xml.bind.v2.bytecode.ClassTailor.noOptimize

rem --------------------------------------------------------------------


echo Java environment:
echo JAVA_HOME = %JAVA_HOME%
echo JAVA_OPTS = %JAVA_OPTS%
echo.
 
rem LS_HOME takes the current directory of LS.bat and goes up two dirs
set LS_HOME=%~dp0..\..\

echo Lightstreamer Server directory:
echo LS_HOME = %LS_HOME%
echo.

   
rem Main configuration file: the default can be changed by the caller
rem by setting the optional LS_CONFIG variable to an absolute path
 
if not ""%LS_CONFIG%"" == """" goto doneConfig
set LS_CONFIG="%LS_HOME%\conf\lightstreamer_conf.xml"
:doneConfig

echo Lightstreamer Server main configuration file:
echo LS_CONFIG = %LS_CONFIG%
echo.


rem Base Classpaths
set bootpath="%LS_HOME%\lib\ls-bootstrap.jar"
set kernelpath="%LS_HOME%\lib\lightstreamer.jar"
set mpnmodulepath="%LS_HOME%\lib\ls-mpn.jar"
 
set intfpath="%LS_HOME%\lib\adapters\*"
set internalpath="%LS_HOME%\lib\ls-monitor.jar";"%LS_HOME%\lib\core\*"
set logpath="%LS_HOME%\lib\ls-logging-utilities.jar";"%LS_HOME%\lib\log\*"
set mpnpath="%LS_HOME%\lib\mpn\*";"%LS_HOME%\lib\mpn\apple\*";"%LS_HOME%\lib\mpn\google\*";"%LS_HOME%\lib\mpn\hibernate\*"
set logbridgepath="%LS_HOME%\lib\log\bridge\*"
 
if ""%1"" == ""run"" goto doStart
if ""%1"" == ""silent"" goto doStart
if ""%1"" == ""background"" goto doStart
if ""%1"" == ""stop"" goto doStop
if ""%1"" == ""restart"" goto doStop
goto doHelp
   
:doStart
 
   echo Starting Lightstreamer Server...
   echo Please check logs for detailed information.
   set class=com.lightstreamer.LS
 
   rem Classpath
   set cpath=%bootpath%;%intfpath%
   rem If you need to share slf4j/logback among the Server and all Adapters, empty LOGGING_LIB_PATH below and move all the involved libraries in cpath; then also remove the reference to the "logbridgepath" libraries below
 
   set KERNEL_LIB_PATH=-Dcom.lightstreamer.kernel_lib_path=%kernelpath%
   set INTERNAL_LIB_PATH=-Dcom.lightstreamer.internal_lib_path=%internalpath%;%logbridgepath%
   set LOGGING_LIB_PATH=-Dcom.lightstreamer.logging_lib_path=%logpath%
   set MPN_LIB_PATH=-Dcom.lightstreamer.mpn_lib_path=%mpnmodulepath%;%mpnpath%
 
   goto doLaunch

:doStop
 
   echo Stopping Lightstreamer Server...
   set class=com.lightstreamer.LS_Stop
   set JAVA_OPTS=
 
   rem Classpath
   set cpath=%bootpath%
 
   goto doLaunch

:doHelp
 
   echo Usage:  LS.bat ( command )
   echo commands:
   echo   run               Start Lightstreamer Server in the current window
   echo   background        Start Lightstreamer Server in a separate window
   echo   stop              Stop Lightstreamer Server
   echo   restart           Stop Lightstreamer Server and start a new instance in a separate window
   goto end
    
 
:doLaunch
   
rem Configuration file
set args=%LS_CONFIG%
 
if ""%1"" == ""run"" goto doForeground
if ""%1"" == ""silent"" goto doSilent
if ""%1"" == ""background"" goto doBackground
if ""%1"" == ""stop"" goto doStop
if ""%1"" == ""restart"" goto doSubcall

:doSubcall
   rem call command and wait
   set command="%JAVA_HOME%\bin\java.exe" %JAVA_OPTS% -cp %cpath% %class% %args%
   call %command%
   %0 background
   goto end

:doForeground
   rem leave control to command
   set command="%JAVA_HOME%\bin\java.exe" %JAVA_OPTS% %KERNEL_LIB_PATH% %INTERNAL_LIB_PATH% %LOGGING_LIB_PATH% %MPN_LIB_PATH% -cp %cpath% %class% %args%
   %command%
   goto end

:doStop
   rem leave control to command
   set command="%JAVA_HOME%\bin\java.exe" %JAVA_OPTS% -cp %cpath% %class% %args%
   %command%
   goto end

:doBackground
   rem call command in a separate window and leave
   set command="%JAVA_HOME%\bin\java.exe" %JAVA_OPTS% %KERNEL_LIB_PATH% %INTERNAL_LIB_PATH% %LOGGING_LIB_PATH% %MPN_LIB_PATH% -cp %cpath% %class% %args%
   if not "%OS%" == "Windows_NT" goto noTitle
   start "Lightstreamer Server" %command%
   goto end
   :noTitle
      start %command%
      goto end

:doSilent
   rem rerun after output redirection (for run as a service)
   set output="%LS_HOME%\logs\LS.out"
   %0 run 1>> %output% 2>&1
   goto end
   
:end
exit /b %ERRORLEVEL%
