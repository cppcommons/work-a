::C:\D\dmd2\windows\bin\dmd.exe -I=lib app.d lib/pegged-dm32.lib winhttp-dm32.lib
implib sqlite3-dm32.lib sqlite3.dll
setlocal
call "C:/Program Files (x86)/Microsoft Visual Studio 14.0/VC/vcvarsall.bat" x86
echo on
::C:\D\dmd2\windows\bin\dmd.exe -m32mscoff -I=lib app2.d lib/pegged-ms32.lib winhttp.lib
if not exist sqlite3-ms32.lib lib /def:sqlite3.def /machine:x86 /out:sqlite3-ms32.lib
endlocal
if %errorlevel% neq 0 (
  echo errorlevel is %errorlevel%.
  exit /b
)
if not exist libcurl.dll copy C:\D\dmd2\windows\bin\libcurl.dll .
