function InitializeModule {
    # Paths

    $Script:GamePath = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 294100' -Name 'InstallLocation').InstallLocation
    $Script:GameModPath = Join-Path $Script:GamePath 'Mods'
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
        'RimWorld'
    )    
    $Script:ModConfigPath = [System.IO.Path]::Combine(
        $Script:UserSettings,
        'Config',
        'ModsConfig.xml'
    )
    $Script:ModProfilePath = Join-Path $Script:UserSettings 'ModProfiles'

    # Cache

    $Script:ModSearchCache = @{}

    # Set-up

    if ((Test-Path $Script:UserSettings) -and -not (Test-Path $Script:ModProfilePath)) {
        $null = New-Item $Script:ModProfilePath -ItemType Directory
    }
}