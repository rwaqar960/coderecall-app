# Copies bundled course packs from the sibling coderecall-content repo into
# app assets. Run from anywhere:  powershell -File tool\sync-content.ps1
# Bundled pack list lives in assets/content/packs.json.

$app = Resolve-Path (Join-Path $PSScriptRoot "..")
$content = Resolve-Path (Join-Path $app "..\coderecall-content")
$packs = (Get-Content (Join-Path $app "assets\content\packs.json") -Raw -Encoding utf8 | ConvertFrom-Json).bundled

foreach ($id in $packs) {
    $src = Join-Path $content "courses\$id"
    $dst = Join-Path $app "assets\content\$id"
    if (-not (Test-Path $src)) { throw "No such course in content repo: $id" }
    if (Test-Path $dst) { Remove-Item -Recurse -Force $dst }
    Copy-Item -Recurse $src $dst
    Write-Output "Synced pack: $id"
}
