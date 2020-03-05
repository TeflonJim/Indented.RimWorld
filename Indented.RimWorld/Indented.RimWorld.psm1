$private = @(
    'ConvertFromXElement'
)

foreach ($file in $private) {
    . ("{0}\private\{1}.ps1" -f $psscriptroot, $file)
}

$public = @(
    'Clear-RWModConfig'
    'Compare-RWModDef'
    'Compare-RWModProfile'
    'Copy-RWModDef'
    'Disable-RWMod'
    'Edit-RWModProfile'
    'Enable-RWMod'
    'Get-RWMod'
    'Get-RWModConfig'
    'Get-RWModDef'
    'Get-RWModProfile'
    'Get-RWVersion'
    'Import-RWModProfile'
    'Open-RWDirectory'
    'Set-RWGamePath'
)

foreach ($file in $public) {
    . ("{0}\public\{1}.ps1" -f $psscriptroot, $file)
}

$functionsToExport = @(
    'Clear-RWModConfig'
    'Compare-RWModDef'
    'Compare-RWModProfile'
    'Copy-RWModDef'
    'Disable-RWMod'
    'Edit-RWModProfile'
    'Enable-RWMod'
    'Get-RWMod'
    'Get-RWModConfig'
    'Get-RWModDef'
    'Get-RWModProfile'
    'Get-RWVersion'
    'Import-RWModProfile'
    'Open-RWDirectory'
    'Set-RWGamePath'
)
Export-ModuleMember -Function $functionsToExport

. ("{0}\InitializeModule.ps1" -f $psscriptroot)
InitializeModule
