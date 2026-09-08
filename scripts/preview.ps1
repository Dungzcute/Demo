param([switch]$Stop)
. "$PSScriptRoot/env.ps1"
$logDirectory = Join-Path $projectRoot '.logs'
$stateFile = Join-Path $logDirectory 'preview.json'

if ($Stop) {
    if (Test-Path -LiteralPath $stateFile) {
        foreach ($entry in (Get-Content -LiteralPath $stateFile -Raw | ConvertFrom-Json)) {
            $process = Get-Process -Id $entry.id -ErrorAction SilentlyContinue
            if ($process -and $process.StartTime.ToUniversalTime().Ticks.ToString() -eq $entry.started) {
                Stop-Process -Id $process.Id
            }
        }
        Remove-Item -LiteralPath $stateFile
    }
    Write-Host 'Preview stopped.'
    exit 0
}

foreach ($port in @(8080, 4200)) {
    $listener = Get-NetTCPConnection -State Listen -LocalPort $port -ErrorAction SilentlyContinue
    if ($listener) { throw "Port $port is already in use. Stop the existing server first (stop-app.bat for this preview)." }
}
if (-not (Test-Path "$projectRoot/backend/target/interview-demo-1.0.0.jar") -or -not (Test-Path "$projectRoot/frontend/node_modules/@angular/cli/bin/ng.js")) {
    throw 'Run setup.bat first.'
}
New-Item -ItemType Directory -Force -Path $logDirectory | Out-Null
$backendProcess = Start-Process -FilePath "$env:JAVA_HOME/bin/java.exe" -ArgumentList '-jar','target/interview-demo-1.0.0.jar' -WorkingDirectory "$projectRoot/backend" -WindowStyle Hidden -RedirectStandardOutput "$logDirectory/backend.log" -RedirectStandardError "$logDirectory/backend-error.log" -PassThru
@(@{ id = $backendProcess.Id; started = $backendProcess.StartTime.ToUniversalTime().Ticks.ToString() }) | ConvertTo-Json | Set-Content -LiteralPath $stateFile
try {
    $frontendProcess = Start-Process -FilePath "$nodeDirectory/node.exe" -ArgumentList 'node_modules/@angular/cli/bin/ng.js','serve','--host','127.0.0.1','--port','4200' -WorkingDirectory "$projectRoot/frontend" -WindowStyle Hidden -RedirectStandardOutput "$logDirectory/frontend.log" -RedirectStandardError "$logDirectory/frontend-error.log" -PassThru
    @(
        @{ id = $backendProcess.Id; started = $backendProcess.StartTime.ToUniversalTime().Ticks.ToString() }
        @{ id = $frontendProcess.Id; started = $frontendProcess.StartTime.ToUniversalTime().Ticks.ToString() }
    ) | ConvertTo-Json | Set-Content -LiteralPath $stateFile
} catch {
    Stop-Process -Id $backendProcess.Id -ErrorAction SilentlyContinue
    throw
}
Write-Host 'Starting app at http://127.0.0.1:4200. Logs: .logs/. Stop with stop-app.bat.'
