# Source loader - Allows the module to be loaded without build

Get-ChildItem (Join-Path $psscriptroot 'source') -Recurse -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}

if (Test-Path (Join-Path $psscriptroot 'source\InitializeModule.ps1')) {
    InitializeModule
}