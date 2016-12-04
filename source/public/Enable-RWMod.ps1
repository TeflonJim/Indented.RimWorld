function Enable-RWMod {
    # .SYNOPSIS
    #   ENable a mod in the list of active mods.
    # .DESCRIPTION
    #   Adds a single mod to the list of active mods.
    # .INPUTS
    #   System.String
    # .OUTPUTS
    #   None
    # .NOTES
    #   Author: Chris Dent
    #
    #   Change log:
    #     11/10/2016 - Chris Dent - Created.

    [CmdletBinding(DefaultParameterSetName = 'ByID', SupportsShouldProcess = $true)]
    [OutputType([System.Void])]
    param(
        # The ID of a mod to disable. The ID is the folder name which may match the name of the mod as seen in RimWorld.
        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByID')]
        [String]$ID,

        # The name of the mod as seen in RimWorld.
        [Parameter(Mandatory = $true, ParameterSetName = 'ByName')]
        [String]$Name,

        # The position the mod should be loaded in. By default mods are added to the end of the list of active mods.
        [ValidateRange(2, 1024)]
        [Int32]$LoadOrder = 1024
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
            if ($LoadOrder -gt @($content.ModsConfigData.activeMods).Count) {
                $predecessorID = @($content.ModsConfigData.activeMods.li)[-1]
            } else {
                $predecessorID = @($content.ModsConfigData.activeMods.li)[($LoadOrder - 1)]
            }
            if ($pscmdlet.ShouldProcess(('Adding {0} to the active mods list' -f $ID))) {
                $content.ModsConfigData.activeMods.SelectSingleNode(('./li[.="{0}"]' -f $predecessorID)).
                                                   CreateNavigator().
                                                   InsertAfter(('<li>{0}</li>' -f [System.Web.HttpUtility]::HtmlAttributeEncode($ID)))
            }
        }
    }

    end {
        if ($pscmdlet.ParameterSetName -eq 'ByID') {
            $content.Save($Script:ModConfigPath)
        }
    }
}