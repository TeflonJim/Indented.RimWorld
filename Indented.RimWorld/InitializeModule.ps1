$Script:ModuleConfigPath = [System.IO.Path]::Combine(
    [Environment]::GetFolderPath('MyDocuments'),
    'PowerShell',
    'Config',
    'Indented.Rimworld.config'
)

if (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 294100') {
    $Script:GamePath = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 294100' -Name 'InstallLocation').InstallLocation
} elseif (Test-Path $Script:ModuleConfigPath) {
    $Script:GamePath = (ConvertFrom-Json (Get-Content $Script:ModuleConfigPath -Raw)).GamePath
} else {
    Write-Warning 'GamePath is not discoverable and not set. Please set a game path with Set-RWGamePath'
}

$Script:GameVersion = [Version]((Get-Content (Join-Path $Script:GamePath 'Version.txt') -Raw) -replace ' .+$')
$Script:GameModPath = Join-Path $Script:GamePath 'Mods'
$Script:GameExpansionPath = Join-Path $Script:GamePath 'Data'

$Script:WorkshopModPath = [System.IO.Path]::Combine(
    ([System.IO.DirectoryInfo]$Script:GamePath).Parent.Parent.FullName,
    'workshop',
    'content',
    '294100'
)

$Script:UserSettings = [System.IO.Path]::Combine(
    $env:USERPROFILE,
    'AppData',
    'LocalLow',
    'Ludeon Studios',
    'RimWorld by Ludeon Studios'
)

$Script:ModListPath = [System.IO.Path]::Combine(
    $Script:UserSettings,
    'ModLists',
    'Main.xml'
)

$Script:ModProfilePath = Join-Path $Script:UserSettings 'ModProfiles'

# Cache

$Script:ModSearchCache = @{}
$Script:ModPackageIdCache = @{}

# Set-up

if ((Test-Path $Script:UserSettings) -and -not (Test-Path $Script:ModProfilePath)) {
    $null = New-Item $Script:ModProfilePath -ItemType Directory
}
