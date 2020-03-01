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

    [CmdletBinding(DefaultParameterSetName = 'ByID', SupportsShouldProcess)]
    [OutputType([System.Void])]
    param (
        # The ID of a mod to disable. The ID is the folder name which may match the name of the mod as seen in RimWorld.
        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName, ParameterSetName = 'ByID')]
        [String]$ID,

        # The name of the mod as seen in RimWorld.
        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [String]$Name
    )

    begin {
        if ($pscmdlet.ParameterSetName -eq 'ByName') {
            Get-RWMod -Name $Name | Disable-RWMod
        }
        if ($pscmdlet.ParameterSetName -eq 'ByID') {
            $content = [XML](Get-Content $Script:ModConfigPath -Raw)
        }
    }

    process {
        if ($pscmdlet.ParameterSetName -eq 'ByID') {
            if ($pscmdlet.ShouldProcess(('Removing {0} from the active mods list' -f $ID))) {
                $content.ModsConfigData.activeMods.SelectSingleNode(('./li[.="{0}"]' -f $ID)).
                                                   CreateNavigator().
                                                   DeleteSelf()
            }
        }
    }

    end {
        if ($pscmdlet.ParameterSetName -eq 'ByID') {
            $content.Save($Script:ModConfigPath)
        }
    }
}
