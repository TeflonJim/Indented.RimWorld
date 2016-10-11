function Edit-RWModProfile {
    param(
        [Parameter(Position = 1, ParameterSetName = 'ByProfileName')]
        [String]$ProfileName = 'DefaultModProfile'
    )

    $Path = Join-Path $Script:UserSettings ('{0}.txt' -f $ProfileName)
    if (-not (Test-Path $Path)) {
        $null = New-Item $Path -ItemType File
    }
    if (Test-Path $Path) {
        notepad $Path
    }
}