function Import-RWModProfile {
    [CmdletBinding(DefaultParameterSetName = 'ByProfileName')]
    param(
        [Parameter(Position = 1, ParameterSetName = 'ByProfileName')]
        [String]$ProfileName = 'Default',

        [Parameter(ParameterSetName = 'FromPath')]
        [ValidateScript( { Test-Path $_ } )]
        [String]$Path,

        [Parameter(ParameterSetName = 'FromString')]
        [String]$ModProfile
    )

    if ($pscmdlet.ParameterSetName -eq 'ByProfileName') {
        $Path = Join-Path $Script:ModProfilePath ('{0}.txt' -f $ProfileName)
    }

    if (-not [String]::IsNullOrEmpty($Path) -and (Test-Path $Path -PathType Leaf)) {
        $ModProfile = Get-Content $Path -Raw
    }

    if (-not [String]::IsNullOrEmpty($ModProfile)) {
        Clear-RWModConfig
        foreach ($mod in $ModProfile.Split("`r`n", [System.StringSplitOptions]::RemoveEmptyEntries)) {
            $mod = $mod.Trim()
            if ($mod -and -not $mod.StartsWith('#')) {
                $rwMod = Get-RWMod -Name $mod
                if ($rwMod) {
                    Write-Verbose ('Enabling mod {0}' -f $mod)

                    $rwMod | Enable-RWMod
                } else {
                    Write-Warning ('Unable to find mod {0}' -f $mod)
                }
            }
        }
    }
}