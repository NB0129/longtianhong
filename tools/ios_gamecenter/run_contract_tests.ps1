param(
    [Parameter(Mandatory = $true)]
    [string]$GodotExe
)

$ErrorActionPreference = "Stop"
$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..\..")).Path
$fixtureRoot = Join-Path $PSScriptRoot "tests\fixture"
$runtimeRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("machiate-gamecenter-contract-" + [System.Guid]::NewGuid().ToString("N"))
$harnessRoot = Join-Path $runtimeRoot "harness"
$logPath = Join-Path $runtimeRoot "test.log"
$previousAppData = $env:APPDATA

if (-not (Test-Path -LiteralPath $GodotExe -PathType Leaf)) {
    throw "Godot executable not found: $GodotExe"
}
if (-not (Test-Path -LiteralPath $fixtureRoot -PathType Container)) {
    throw "Test fixture not found: $fixtureRoot"
}

try {
    New-Item -ItemType Directory -Path $harnessRoot -Force | Out-Null
    Copy-Item -Path (Join-Path $fixtureRoot "*") -Destination $harnessRoot -Recurse -Force
    Copy-Item -LiteralPath (Join-Path $projectRoot "IOSGameCenterAdapter.gd") -Destination $harnessRoot -Force
    New-Item -ItemType Directory -Path (Join-Path $harnessRoot "candidate") -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $projectRoot "RankingManager.gd") -Destination (Join-Path $harnessRoot "candidate\RankingManager.gd") -Force
    $env:APPDATA = Join-Path $runtimeRoot "appdata"
    New-Item -ItemType Directory -Path $env:APPDATA -Force | Out-Null

    & $GodotExe --headless --path $harnessRoot --log-file $logPath --quit
    $exitCode = $LASTEXITCODE
    $logText = Get-Content -LiteralPath $logPath -Raw
    if ($exitCode -ne 0 -or $logText -match "SCRIPT ERROR|Parse Error|Failed to load script") {
        Write-Output $logText
        throw "iOS Game Center contract tests failed with exit code $exitCode"
    }
    $passLine = Select-String -LiteralPath $logPath -Pattern "^PASS: "
    if (-not $passLine) {
        Write-Output $logText
        throw "iOS Game Center contract tests did not report PASS"
    }
    Write-Output $passLine.Line
}
finally {
    $env:APPDATA = $previousAppData
    $resolvedTemp = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
    $resolvedRuntime = [System.IO.Path]::GetFullPath($runtimeRoot)
    if ($resolvedRuntime.StartsWith($resolvedTemp, [System.StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $resolvedRuntime)) {
        Remove-Item -LiteralPath $resolvedRuntime -Recurse -Force
    }
}
