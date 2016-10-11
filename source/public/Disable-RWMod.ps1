function Disable-RWMod {
    [CmdletBinding(DefaultParameterSetName = 'ByID')]
    param(
        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByID')]
        [String]$ID,

        [Parameter(Mandatory = $true, ParameterSetName = 'ByName')]
        [String]$Name
    )

    begin {
        $content = [XML](Get-Content $Script:ModConfigPath -Raw)
    }

    process {
        $content.ModsConfigData.activeMods.SelectSingleNode(('./li[.="{0}"]' -f $ID)).
                                           CreateNavigator().
                                           DeleteSelf()
    }

    end {
        $content.Save($Script:ModConfigPath)
    }
}