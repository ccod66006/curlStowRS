@echo off

for /f "tokens=1,2 delims==" %%a in (config.txt) do (
    if "%%a"=="token_url" set "token_url=%%b"
    if "%%a"=="upload_url" set "upload_url=%%b"
    if "%%a"=="client_id" set "client_id=%%b"
    if "%%a"=="client_secret" set "client_secret=%%b"
)
echo Token URL: %token_url%
echo Upload URL: %upload_url%
echo Client ID: %client_id%
echo Client Secret: %client_secret%

:: Step 1: Get the token
echo Getting the token...
curl --location --request POST "%token_url%" ^
     --header "Content-Type: application/x-www-form-urlencoded" ^
     --data-urlencode "grant_type=client_credentials" ^
     --data-urlencode "client_id=%client_id%" ^
     --data-urlencode "client_secret=%client_secret%" > token_response.json

:: Extract the token from the response
for /f "tokens=2 delims=:," %%a in ('findstr /i "access_token" token_response.json') do set token=%%a
set token=%token:~1,-1%

:: Step 2: Upload the files using the token
echo Uploading files...
setlocal enabledelayedexpansion
for %%f in (files\*) do (
    echo Uploading %%f...

    :: Construct the URL
    set "url=%upload_url%"
    echo URL: !url!
    
    curl --location --request POST "!url!" ^
         --header "Accept: application/dicom+json" ^
         --header "Content-Type: multipart/related; type=\"application/dicom\"" ^
         --header "Authorization: Bearer %token%" ^
         --form "file1=@%%f;type=application/dicom" > upload_response.json

    echo Response for %%f:
    type upload_response.json
    echo.
)

pause
