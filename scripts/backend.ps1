. "$PSScriptRoot/env.ps1"
& mvn.cmd "-Dmaven.repo.local=$projectRoot/.tools/m2" -f "$projectRoot/backend/pom.xml" spring-boot:run --no-transfer-progress
exit $LASTEXITCODE
