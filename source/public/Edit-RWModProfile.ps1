function Edit-RWModProfile {
    param(
        [Parameter(Position = 1, ParameterSetName = 'ByProfileName')]
        [String]$ProfileName = 'Default'
    )

    $path = Join-Path $Script:ModProfilePath ('{0}.txt' -f $ProfileName)
    if (-not (Test-Path $path)) {
        $null = New-Item $path -ItemType File
    }
    if (Test-Path $path) {
        notepad $path
    }
}