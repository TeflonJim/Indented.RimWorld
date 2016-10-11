function InitializeModule {
    $Script:UserSettings = Join-Path $env:USERPROFILE 'AppData\LocalLow\Ludeon Studios\RimWorld\Config'
    $Script:ModConfigPath = Join-Path $Script:UserSettings 'ModsConfig.xml'
    $Script:GamePath = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 294100' -Name 'InstallLocation').InstallLocation
    $Script:GameModPath = Join-Path $Script:GamePath 'Mods'
    $Script:WorkshopModPath = Join-Path ([System.IO.DirectoryInfo]$Script:GamePath).Parent.Parent.FullName 'workshop\content\294100'
    $Script:ModSearchCache = @{}
}