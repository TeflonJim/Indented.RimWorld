function Get-RWModList {
    <#
    .SYNOPSIS
        Get the list of active mods.
    .DESCRIPTION
        Get-RWModConfig reads the activeMods list from ModsConfig.xml.
    #>

    [CmdletBinding()]
    [OutputType('Indented.RimWorld.ModInformation')]
    param (
        # The name of the mod as seen in RimWorld.
        [string]$Name
    )

    if (Test-Path -Path $Script:ModListPath) {
        $modList = [Xml]::new()
        $modList.Load($Script:ModListPath)

        $i = 1
        foreach ($mod in $modList.ModList.modIds.li) {
            $modInformation = Get-RWMod -PackageId $mod |
                Add-Member LoadOrder $i -PassThru |
                Add-Member -TypeName Indented.RimWorld.ModLoadInformation -PassThru
            if (-not $modInformation) {
                $modInformation = [PSCustomObject]@{
                    Name              = $mod
                    ID                = $mod
                    PackageID         = $mod
                    SupportedVersions = @()
                    LoadOrder         = $i
                    PSTypeName        = 'Indented.RimWorld.ModLoadInformation'
                }
            }

            if ([String]::IsNullOrEmpty($Name) -or $Name.IndexOf('*') -gt -1) {
                $modInformation
            } elseif ($modInformation.Name -eq $Name -or $mod -eq $Name) {
                return $modInformation
            }
            $i++
        }
    }
}
