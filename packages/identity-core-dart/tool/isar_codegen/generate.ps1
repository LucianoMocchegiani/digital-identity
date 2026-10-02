# Regenera lib/src/record/isar/*.g.dart con isar_community_generator.
# Uso (desde identity-core-dart/): .\tool\isar_codegen\generate.ps1
# Los modelos Isar solo importan isar_community, así que se generan acá
# sin chocar con freezed/json_serializable del paquete principal.
$ErrorActionPreference = 'Stop'
$root = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$src = Join-Path $root 'lib\src\record\isar'
$work = Join-Path $PSScriptRoot 'lib'

if (Test-Path $work) { Remove-Item $work -Recurse -Force }
New-Item -ItemType Directory $work | Out-Null
Get-ChildItem $src -Filter '*.dart' | Where-Object { $_.Name -notlike '*.g.dart' } |
  Copy-Item -Destination $work

Push-Location $PSScriptRoot
try {
  dart pub get
  dart run build_runner build
} finally {
  Pop-Location
}

Get-ChildItem $work -Filter '*.g.dart' | Copy-Item -Destination $src -Force
Remove-Item $work -Recurse -Force
Write-Host "OK: .g.dart actualizados en $src"
