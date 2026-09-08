. "$PSScriptRoot/env.ps1"
Push-Location (Join-Path $projectRoot 'frontend')
try { & npm.cmd start; $result = $LASTEXITCODE } finally { Pop-Location }
exit $result
