function Import-RWModProfile {
    <#
    .SYNOPSIS
        Import a mod profile.
    .DESCRIPTION
        Imports a list of mods into the active mods list. This overwrites any existing mods.
    .NOTES
        Change log:
            11/10/2016 - Chris Dent - Created.
    #>

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')] # All commands used by this support ShouldProcess.
    [CmdletBinding(DefaultParameterSetName = 'ByProfileName', SupportsShouldProcess = $true)]
    [OutputType([System.Void])]
    param (
        # The name of a profile to import.
        [Parameter(Position = 1, ParameterSetName = 'ByProfileName')]
        [String]$ProfileName = 'Default',

        # The path to a file containing a profile description.
        [Parameter(ParameterSetName = 'FromPath')]
        [ValidateScript( { Test-Path $_ } )]
        [String]$Path,

        # A list of mods to activate.
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
                    $rwMod | Enable-RWMod
                } else {
                    Write-Warning ('Unable to find mod {0}' -f $mod)
                }
            }
        }
    }
}