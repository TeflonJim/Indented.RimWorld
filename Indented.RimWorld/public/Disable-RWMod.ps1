function Disable-RWMod {
    <#
    .SYNOPSIS
        Disable a mod in the list of active mods.
    .DESCRIPTION
        Removes a single mod from the list of active mods.
    .INPUTS
        System.String
    .NOTES
        Change log:
            11/10/2016 - Chris Dent - Created.
    #>

    [CmdletBinding(DefaultParameterSetName = 'ByPackageID', SupportsShouldProcess)]
    [OutputType([System.Void])]
    param (
        # The ID of a mod to disable. The ID is the folder name which may match the name of the mod as seen in RimWorld.
        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName, ParameterSetName = 'ByPackageID')]
        [String]$PackageID,

        # The name of the mod as seen in RimWorld.
        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [String]$Name
    )

    begin {
        if ($pscmdlet.ParameterSetName -eq 'ByName') {
            Get-RWMod -Name $Name | Disable-RWMod
        }
        if ($pscmdlet.ParameterSetName -eq 'ByPackageID') {
            $content = [XML](Get-Content $Script:ModConfigPath -Raw)
        }
    }

    process {
        if ($pscmdlet.ParameterSetName -eq 'ByPackageID') {
            Write-Verbose ('Removing {0} from the active mods list' -f $PackageID)

            if ($pscmdlet.ShouldProcess(('Removing {0} from the active mods list' -f $PackageID))) {
                $content.ModsConfigData.activeMods.SelectSingleNode(('./li[.="{0}"]' -f $PackageID)).
                                                   CreateNavigator().
                                                   DeleteSelf()
            }
        }
    }

    end {
        if ($pscmdlet.ParameterSetName -eq 'ByPackageID') {
            $content.Save($Script:ModConfigPath)
        }
    }
}
