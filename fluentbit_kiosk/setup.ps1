$fluentbit_service = "fluentbit"

sc.exe stop $fluentbit_service
sc.exe delete $fluentbit_service
Remove-Item -Path "C:\fluentbit.zip" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\fluentbit" -Recurse -Force -ErrorAction SilentlyContinue

$fluentbit_uri = "https://drive.usercontent.google.com/download?id=1x-RztSk1Y9pgCGpIJQhnPhRWzLUeUJb3`&export=download`&authuser=0`&confirm=t`&uuid=f66e71a2-cb16-4d3c-a6e2-ed0d7b487f0d`&at=AIrpjvOPtW3gsd3Fggd0EauWNr5m:1736396899174"

$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $fluentbit_uri -OutFile "C:\fluentbit.zip"
Expand-Archive -Path "C:\fluentbit.zip" -DestinationPath "C:\fluentbit" -Force
Get-ChildItem -Path "C:\fluentbit\fluentbit" -Recurse | Move-Item -Destination "C:\fluentbit" -Force
Remove-Item -Path "C:\fluentbit\fluentbit" -Recurse -Force

sc.exe create $fluentbit_service binPath= "C:\fluentbit\bin\fluent-bit.exe -c C:\fluentbit\conf\fluent-bit.conf" start= auto
sc.exe query $fluentbit_service
sc.exe start $fluentbit_service

Remove-Item -Path "C:\fluentbit.zip" -Recurse -Force -ErrorAction SilentlyContinue
# Remove-Item -Path "C:\fluentbit" -Recurse -Force -ErrorAction SilentlyContinue
