. "$PSScriptRoot/env.ps1"
& mvn.cmd "-Dmaven.repo.local=$projectRoot/.tools/m2" -f "$projectRoot/backend/pom.xml" verify --batch-mode --no-transfer-progress
if ($LASTEXITCODE -ne 0) { throw 'Backend verification failed.' }
Push-Location (Join-Path $projectRoot 'frontend')
try {
    & npm.cmd run build
    if ($LASTEXITCODE -ne 0) { throw 'Frontend build failed.' }
} finally { Pop-Location }
