function Import-RWModProfile {
    <#
    .SYNOPSIS
        Import a mod profile.
    .DESCRIPTION
        Imports a list of mods into the active mods list. This overwrites any existing mods.
    #>

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')] # All commands used by this support ShouldProcess.
    [CmdletBinding(DefaultParameterSetName = 'ByProfileName', SupportsShouldProcess)]
    [OutputType([System.Void])]
    param (
        # The name of a profile to import.
        [Parameter(Position = 1, ParameterSetName = 'ByProfileName')]
        [string]$ProfileName = 'Default',

        # The path to a file containing a profile description.
        [Parameter(ParameterSetName = 'FromPath')]
        [ValidateScript( { Test-Path $_ } )]
        [string]$Path,

        # A list of mods to activate.
        [Parameter(ParameterSetName = 'FromString')]
        [string]$ModProfile
    )

    if ($pscmdlet.ParameterSetName -eq 'ByProfileName') {
        $Path = Join-Path $Script:ModProfilePath ('{0}.txt' -f $ProfileName)
    }

    if (-not [String]::IsNullOrEmpty($Path) -and (Test-Path $Path -PathType Leaf)) {
        $ModProfile = Get-Content $Path -Raw
    }

    if (-not [String]::IsNullOrEmpty($ModProfile)) {
        Clear-RWModList
        $modsToEnable = foreach ($mod in $ModProfile.Split("`r`n", [System.StringSplitOptions]::RemoveEmptyEntries)) {
            $mod = $mod.Trim()
            if ($mod -and -not $mod.StartsWith('#')) {
                $rwMod = Get-RWMod -Name $mod
                if ($rwMod) {
                    if (-not $rwMod.PackageID) {
                        # Strip PackageID and allow Enable-RWMod to report on compatibility by name.
                        $rwMod = $rwMod | Select-Object * -ExcludeProperty PackageID
                    }
                    $rwMod
                } else {
                    Write-Warning ('Unable to find mod {0}' -f $mod)
                }
            }
        }

        # Verify load order
        $allPackageIDs = $modsToEnable.PackageID
        for ($i = 0; $i -lt $modsToEnable.Count; $i++) {
            $rwMod = $modsToEnable[$i]

            foreach ($packageID in $rwMod.Dependencies) {
                if ($allPackageIDs.IndexOf($packageID) -lt 0) {
                    Write-Error ('{0} depends on the missing module {1}' -f $rwMod.Name, $packageID)
                }
            }

            foreach ($packageID in $rwMod.LoadAfter) {
                if ($allPackageIDs.IndexOf($packageID) -gt $i) {
                    Write-Error ('{0} should load after {1}' -f $rwMod.Name, (Get-RWMod -PackageID $packageID).Name)
                }
            }

            foreach ($packageID in $rwMod.LoadBefore) {
                $index = $allPackageIDs.IndexOf($packageID)
                if ($index -gt -1 -and $index -lt $i) {
                    Write-Error ('{0} should load before {1}' -f $rwMod.Name, (Get-RWMod -PackageID $packageID).Name)
                }
            }
        }

        $modsToEnable | Enable-RWMod
    }
}
