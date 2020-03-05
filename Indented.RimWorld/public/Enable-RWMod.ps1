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
    [OutputType([System.Void])]
    param (
        # The ID of a mod to enable. The ID is the folder name which may match the name of the mod as seen in RimWorld.
        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName, ParameterSetName = 'ByPackageID')]
        [String]$PackageID,

        # The name of the mod as seen in RimWorld.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName')]
        [String]$Name,

        # The position the mod should be loaded in. By default mods are added to the end of the list of active mods.
        [ValidateRange(2, 1024)]
        [Int32]$LoadOrder = 1024
    )

    begin {
        $modsConfig = [XML](Get-Content $Script:ModConfigPath -Raw)
    }

    process {
        if ($pscmdlet.ParameterSetName -eq 'ByPackageID') {
            $rwMod = Get-RWMod -PackageId $PackageID
        } else {
            $rwMod = Get-RWMod -Name $Name
        }

        $gameVersion = Get-RWVersion
        if ($rwMod.PackageID -like 'ludeon.*' -or $rwMod.SupportedVersions -contains $gameVersion.ShortVersion) {
            if (-not $rwMod.PackageID) {
                Write-Warning ('Unable to enable mod {0}. Mod does not define a PackageId.' -f $rwMod.Name)
                return
            }

            Write-Verbose ('Enabling mod {0}' -f $rwMod.Name)

            if ($LoadOrder -gt @($modsConfig.ModsConfigData.activeMods).Count) {
                $predecessorID = @($modsConfig.ModsConfigData.activeMods.li)[-1]
            } else {
                $predecessorID = @($modsConfig.ModsConfigData.activeMods.li)[($LoadOrder - 1)]
            }
            if ($pscmdlet.ShouldProcess(('Adding {0} to the active mods list' -f $PackageID))) {
                $activeMods = $modsConfig.SelectSingleNode('/ModsConfigData/activeMods')

                $newNode = $modsConfig.CreateElement('li')
                $newNode.InnerText = $PackageID

                if ($predecessor = $activeMods.SelectSingleNode(('./li[.="{0}"]' -f $predecessorID))) {
                    $null = $activeMods.InsertAfter($newNode, $predecessor)
                } else {
                    $null = $activeMods.AppendChild($newNode)
                }
            }
        } else {
            Write-Warning ('Unable to enable mod {0}. Not compatible with RimWorld version {1}.' -f $rwMod.Name, $gameVersion.ShortVersion)
        }
    }

    end {
        $modsConfig.Save($Script:ModConfigPath)
    }
}
