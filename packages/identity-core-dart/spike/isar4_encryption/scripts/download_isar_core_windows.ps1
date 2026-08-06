# Descargar Isar Core 4.0.0-dev.14 (Windows x64)

$ErrorActionPreference = "Stop"
$outDir = Join-Path $PSScriptRoot "..\native"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
$outFile = Join-Path $outDir "isar.dll"
$url = "https://github.com/isar/isar/releases/download/4.0.0-dev.14/isar_windows_x64.dll"
Write-Host "Descargando $url -> $outFile"
Invoke-WebRequest -Uri $url -OutFile $outFile
Write-Host "Listo."
