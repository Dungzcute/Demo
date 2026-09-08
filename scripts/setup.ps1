$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$toolsDirectory = Join-Path $projectRoot '.tools'
New-Item -ItemType Directory -Force -Path $toolsDirectory | Out-Null

function Install-VerifiedArchive($url, $checksumUrl, $algorithm, $archiveName, $folderName) {
    if (Test-Path -LiteralPath (Join-Path $toolsDirectory $folderName)) { return }
    $archive = Join-Path $toolsDirectory $archiveName
    Write-Host "Downloading $archiveName ..."
    Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $archive
    $checksums = (Invoke-WebRequest -UseBasicParsing -Uri $checksumUrl).Content
    if ($checksums -is [byte[]]) { $checksums = [Text.Encoding]::UTF8.GetString($checksums) }
    if ($algorithm -eq 'SHA256') {
        $line = ($checksums -split "`n" | Where-Object { $_.Trim().EndsWith($archiveName) } | Select-Object -First 1)
        if (-not $line) { throw "No checksum found for $archiveName" }
        $expected = ($line.Trim() -split '\s+')[0]
    } else { $expected = ($checksums.Trim() -split '\s+')[0] }
    $actual = (Get-FileHash -LiteralPath $archive -Algorithm $algorithm).Hash
    if ($actual -ine $expected) { throw "Checksum mismatch for $archiveName" }
    Expand-Archive -LiteralPath $archive -DestinationPath $toolsDirectory -Force
    Remove-Item -LiteralPath $archive
}

Install-VerifiedArchive 'https://nodejs.org/dist/v24.13.0/node-v24.13.0-win-x64.zip' 'https://nodejs.org/dist/v24.13.0/SHASUMS256.txt' 'SHA256' 'node-v24.13.0-win-x64.zip' 'node-v24.13.0-win-x64'
Install-VerifiedArchive 'https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.11/apache-maven-3.9.11-bin.zip' 'https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.11/apache-maven-3.9.11-bin.zip.sha512' 'SHA512' 'apache-maven-3.9.11-bin.zip' 'apache-maven-3.9.11'
. "$PSScriptRoot/env.ps1"
if (-not (Test-Path -LiteralPath (Join-Path $env:JAVA_HOME 'bin/javac.exe'))) { throw 'Please install JDK 21 or newer, then run setup again.' }
Push-Location (Join-Path $projectRoot 'frontend')
try {
    if (Test-Path -LiteralPath 'package-lock.json') { & npm.cmd ci --no-fund --cache "$toolsDirectory/npm-cache" }
    else { & npm.cmd install --no-fund --cache "$toolsDirectory/npm-cache" }
    if ($LASTEXITCODE -ne 0) { throw 'npm install failed.' }
} finally { Pop-Location }
& mvn.cmd "-Dmaven.repo.local=$toolsDirectory/m2" -f "$projectRoot/backend/pom.xml" package --batch-mode --no-transfer-progress
if ($LASTEXITCODE -ne 0) { throw 'Backend build failed.' }
Write-Host 'Setup complete. Run run-backend.bat and run-frontend.bat.' -ForegroundColor Green
