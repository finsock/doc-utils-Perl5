:: KIC Reject Deployment Prompt 1.1
:: Open a command prompt to compile kic_reject.pl
:: Copyright (C) 2017  Csaba Gaspar
::
:: Version 1.1 created on 08.14.2017
:: Compiling libexpat-1__.dll into the executable for those not having 
:: Strawberry Perl installed. The modified line is as follows:
:: CMD /C pp -l "libexpat-1__.dll" -x -g -o kic_reject.exe kic_reject.pl

@echo off
setlocal

title KIC Reject Deployment Prompt

	cls

	echo.
	echo KIC Reject Deployment Prompt 1.1
	echo.

	pause
	
:: If any of the main dependencies (source file, perl interpreter, perl 
:: packager) is missing from the current development environment, where
:: this batch file is being run, we can't proceede.

	echo.
	echo Checking dependencies...

	where /q kic_reject.pl
	if not errorlevel 0 (
		echo Could not find target script 'kic_reject.pl'. 
		goto error
	) else (
		echo - The target script is available.
	)

	where /q perl.exe
	if not errorlevel 0 (
		echo Could not find a Perl interpreter installed on this sytem. 
		goto error
		
	) else (
		echo - Perl interpreter is installed.
	)
	
	where /q pp.exe
	if not errorlevel 0 (
		echo Could not find PAR on this sytem. 
		goto error
	) else (
		echo - Perl packager is installed.
	)
	
:: If the kic_reject.exe executable exists, this is a re-compilation 
:: attempt, where the existing configuration files need to be preserved.

	echo.
	echo Checking consistency..
	if exist "kic_reject.exe" (
		echo - Configuration and template files seem to exist.
		set /P SHOULDWEBACKUP= - Should we backup them? (Y/[N])
		if /I "%SHOULDWEBACKUP%" NEQ "Y" (
			echo Existing configuration and template files will not be backed up.
		) else (
			echo - Existing configuration and template files are being backed up. 
			md backup
			copy *.ini backup\*.ini >nul
			copy *.tmpl backup\*.tmpl >nul
			copy *.log backup\*.log >nul
			copy *.config backup\*.config >nul
			copy *.lnk backup\*.lnk >nul
			copy *.ico backup\*.ico >nul
			echo - backup is completed		
		)		
	) else ( 
		echo - Configuration and template files don't seem to exist. 
	)

:: If this is the first compilation attempt in the current directory, where 
:: the source file and the batch file currently resides, we need to generate
:: all the configuration and template files the application needs. If this is 
:: a re-compilation attempt, missing configuration and template files will be
:: re-introduced to the configuration. Calling the perl script from the command 
:: line with an 'a' switch automatically generates all the necessary accessories
:: into a temporary sub-folder in the application directory.

	echo.
	echo Preparing new environment...
	echo   (Please be prepared to acknowledge an application GUI feedback).
	CMD /C perl kic_reject.pl -a
	echo - Configuration and template files are generated.
	copy /y temp\*.* *.* >nul
	echo - Configuration and template files are copied to destination.

:: The compilation of the perl script is done by MinGW (Strawberry perl contains a 
:: fully featured C/C++ compiler) and the perl packager (pp) utility, 
:: which is part of the PAR distribution (a perl cross-platform packaging and 
:: deployment tool). The 'x' switch forces the packager to run the application
:: during the packaging process to determine additional run-time dependencies.
:: The 'g' switch creates a consoleless excecutable, the 'o' switch renames
:: the executable to 'kic_reject.exe'. Because of the 'x' switch, you can expect
:: some interaction with the application during the compilation/packaging time. 
:: This may take some time, so please don't interrupt the compilation/packaging 
:: process by closing the application abruptly (just wait until the first dialogue
:: window appears and press OK to properly abort the program - that how the 
:: compiler and packager will be able to do their job to find any missing 
:: component in the development environment to provide with a reliable result). 
 
	echo.
	echo Compiling perl script...
	echo - Determining additional run-time dependencies (this may take a while).
	echo   (Please be prepared to acknowledge an application GUI feedback).
	CMD /C pp -l "libexpat-1__.dll" -x -g -o kic_reject.exe kic_reject.pl
	echo - Compilation is done.

:: If the backup folder exists, there are configuration and template files we need
:: to restore in the application folder. These may carry custom changes which are 
:: not available in the default files generated during the re-compilation, so those
:: changes need to be preserved. When the restoration is completed, the temporary 
:: and backup folders can be deleted with their contents.
 
	echo.
	echo Checking consistency...
	if exist "backup" (
		echo - Restoring original configuration and template files.
		copy /y backup\*.* *.* >nul
		echo - Restoration is completed.
		del /q backup
		rmdir backup
		echo - Backup folder is deleted.
	)
	if exist "temp" (
		del /q temp
		rmdir temp
		echo - Temporary folder is deleted.
	)

	echo.
	echo All tasks have been successfully completed.
	echo.

	echo Press any key to exit.
	pause >nul

	exit

:error
	echo.
	echo Something went wrong, the compilation has not been completed.
	echo.

	echo Press any key to exit.
	pause >nul
	
	exit
