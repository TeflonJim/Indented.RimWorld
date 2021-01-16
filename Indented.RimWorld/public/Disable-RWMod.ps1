function Disable-RWMod {
    <#
    .SYNOPSIS
        Disable a mod in the list of active mods.
    .DESCRIPTION
        Removes a single mod from the list of active mods.
    .INPUTS
        System.String
    #>

    [CmdletBinding(DefaultParameterSetName = 'ByPackageID', SupportsShouldProcess)]
    [OutputType([void])]
    param (
        # The ID of a mod to disable. The ID is the folder name which may match the name of the mod as seen in RimWorld.
        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName, ParameterSetName = 'ByPackageID')]
        [string]$PackageID,

        # The name of the mod as seen in RimWorld.
        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [string]$Name
    )

    begin {
        if ($pscmdlet.ParameterSetName -eq 'ByName') {
            Get-RWMod -Name $Name | Disable-RWMod
        }
        if ($pscmdlet.ParameterSetName -eq 'ByPackageID') {
            $modList = [Xml]::new()
            $modList.Load($Script:ModListPath)
        }
    }

    process {
        if ($pscmdlet.ParameterSetName -eq 'ByPackageID') {
            Write-Verbose ('Removing {0} from the active mods list' -f $PackageID)

            $rwMod = Get-RWMod -PackageID $PackageID

            if ($pscmdlet.ShouldProcess(('Removing {0} from the active mods list' -f $PackageID))) {
                $modList.ModList.modIds.SelectSingleNode(('./li[.="{0}"]' -f $PackageID)).
                    CreateNavigator().
                    DeleteSelf()

                $modList.ModList.modNames.SelectSingleNode(('./li[.="{0}"]' -f $rwMod.Name)).
                    CreateNavigator().
                    DeleteSelf()
            }
        }
    }

    end {
        if ($pscmdlet.ParameterSetName -eq 'ByPackageID') {
            $modList.Save($Script:ModListPath)
        }
    }
}
