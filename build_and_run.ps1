$sdkPath = (Get-Content "$env:APPDATA\Garmin\ConnectIQ\current-sdk.cfg").Trim()
$device = "fenix7spro"

Write-Host "Compiling Weight Tracker for $device..." -ForegroundColor Cyan
& "$sdkPath\bin\monkeyc.bat" -f monkey.jungle -d $device -o bin\WeightTracker.prg -y developer_key -w

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build Successful! Starting simulator..." -ForegroundColor Green
    if (-not (Get-Process -Name "simulator" -ErrorAction SilentlyContinue)) {
        Start-Process -FilePath "$sdkPath\bin\simulator.exe"
        Start-Sleep -Seconds 2
    }
    & "$sdkPath\bin\monkeydo.bat" "bin\WeightTracker.prg" $device
} else {
    Write-Host "Build Failed." -ForegroundColor Red
}
