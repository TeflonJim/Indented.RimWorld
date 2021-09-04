function Enable-RWMod {
    <#
    .SYNOPSIS
        Enable a mod in the list of active mods.
    .DESCRIPTION
        Adds a single mod to the list of active mods.
    .INPUTS
        System.String
    .NOTES
        Change log:
            11/10/2016 - Chris Dent - Created.
    #>

    [CmdletBinding(DefaultParameterSetName = 'ByPackageID', SupportsShouldProcess)]
    [OutputType([void])]
    param (
        # The ID of a mod to enable. The ID is the folder name which may match the name of the mod as seen in RimWorld.
        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName, ParameterSetName = 'ByPackageID')]
        [string]$PackageID,

        # The name of the mod as seen in RimWorld.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName')]
        [string]$Name,

        # The position the mod should be loaded in. By default mods are added to the end of the list of active mods.
        [ValidateRange(1, 1024)]
        [int]$LoadOrder = 1024,

        # Add the mod to the load order regardless of the supported version.
        [switch]$Force
    )

    begin {
        $modList = [Xml]::new()
        $modList.Load($Script:ModListPath)

        $gameVersion = Get-RWVersion
    }

    process {
        if ($pscmdlet.ParameterSetName -eq 'ByPackageID') {
            $rwMod = Get-RWMod -PackageId $PackageID
        } else {
            $rwMod = Get-RWMod -Name $Name
        }

        if ($rwMod -and $rwMod.PackageID -like 'ludeon.*' -or $rwMod.SupportedVersions -contains $gameVersion.ShortVersion -or $Force) {
            if (-not $rwMod.PackageID) {
                Write-Warning ('Unable to enable mod {0}. Mod does not define a PackageId.' -f $rwMod.Name)
                return
            }

            Write-Verbose ('Enabling mod {0}' -f $rwMod.Name)

            if ($LoadOrder -gt @($modList.modIds).Count) {
                $predecessorID = @($modList.modIds.li)[-1]
                $predecessorName = @($modList.modNames.li)[-1]
            } elseif ($LoadOrder -gt 1) {
                $predecessorID = @($modList.ModList.modIds.li)[($LoadOrder - 1)]
                $predecessorName = @($modList.ModList.modNames.li)[($LoadOrder - 1)]
            }

            if ($pscmdlet.ShouldProcess(('Adding {0} to the active mods list' -f $PackageID))) {
                $modIds = $modList.SelectSingleNode('/ModList/modIds')
                $idNode = $modList.CreateElement('li')
                $idNode.InnerText = $rwMod.PackageID

                if ($LoadOrder -eq 1) {
                    $null = $modIds.InsertBefore($idNode, $modList.ModList.modIds.SelectSingleNode('(./li)[1]'))
                } elseif ($predecessor = $modIds.SelectSingleNode(('./li[.="{0}"]' -f $predecessorID))) {
                    $null = $modIds.InsertAfter($idNode, $predecessor)
                } else {
                    $null = $modIds.AppendChild($idNode)
                }

                $modNames = $modList.SelectSingleNode('/ModList/modNames')
                $nameNode = $modList.CreateElement('li')
                $nameNode.InnerText = $rwMod.Name

                if ($LoadOrder -eq 1) {
                    $null = $modNames.InsertBefore($nameNode, $modList.ModList.modNames.SelectSingleNode('(./li)[1]'))
                } elseif ($predecessor = $modNames.SelectSingleNode(('./li[.="{0}"]' -f ($predecessorName -replace '"', '\"')))) {
                    $null = $modNames.InsertAfter($nameNode, $predecessor)
                } else {
                    $null = $modNames.AppendChild($nameNode)
                }
            }
        } else {
            Write-Warning ('Unable to enable mod {0}. Not compatible with RimWorld version {1}.' -f $rwMod.Name, $gameVersion.ShortVersion)
        }
    }

    end {
        $modList.Save($Script:ModListPath)
    }
}
