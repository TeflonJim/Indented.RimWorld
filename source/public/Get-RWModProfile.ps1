function Get-RWModProfile {
    # .SYNOPSIS
    #   Get configured mod profiles.
    # .DESCRIPTION
    #   Gets each mod profile and the list of mods it contains.
    # .INPUTS
    #   System.String
    # .OUTPUTS
    #   Indented.RimWorld.ModProfileInformation (System.Management.Automation.PSObject)
    # .NOTES
    #   Author: Chris Dent
    #
    #   Change log:
    #     04/12/2016 - Chris Dent - Created.
    
    [CmdletBinding()]
    [OutputType([System.Management.AUtomation.PSObject])]
    param(
        # The profile name to get. By default the command returns information about all profiles.
        [Parameter(Position = 1, ParameterSetName = 'ByProfileName')]
        [String]$ProfileName = '*'
    )

    Get-ChildItem $Script:ModProfilePath -Filter ('{0}.txt' -f $ProfileName) | ForEach-Object {
        $modProfile = Get-Content $_.FullName -Raw
        $modList = foreach ($mod in $modProfile.Split("`r`n", [System.StringSplitOptions]::RemoveEmptyEntries)) {
            $mod = $mod.Trim()
            if ($mod -and -not $mod.StartsWith('#')) {
                $rwMod = Get-RWMod -Name $mod
                if ($rwMod) {
                    $rwMod
                }
            }
        }
        [PSCustomObject]@{
            ProfileName = $_.BaseName
            ModList     = $modList
        }
    }
}