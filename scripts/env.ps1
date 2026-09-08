$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$nodeDirectory = Join-Path $projectRoot '.tools/node-v24.13.0-win-x64'
$mavenDirectory = Join-Path $projectRoot '.tools/apache-maven-3.9.11'
if (Test-Path -LiteralPath $nodeDirectory) { $env:Path = "$nodeDirectory;$env:Path" }
if (Test-Path -LiteralPath $mavenDirectory) { $env:Path = "$(Join-Path $mavenDirectory 'bin');$env:Path" }
# Maven needs JAVA_HOME to point at the JDK, not Oracle's javapath shim.
$savedErrorPreference = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
$javaSettings = & java -XshowSettings:properties -version 2>&1 | Out-String
$ErrorActionPreference = $savedErrorPreference
if ($javaSettings -match 'java.home\s*=\s*([^\r\n]+)') { $env:JAVA_HOME = $Matches[1].Trim() }
$env:NG_CLI_ANALYTICS = 'false'
