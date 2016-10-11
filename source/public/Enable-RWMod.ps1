function Enable-RWMod {
    [CmdletBinding(DefaultParameterSetName = 'ByID')]
    param(
        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByID')]
        [String]$ID,

        [Parameter(Mandatory = $true, ParameterSetName = 'ByName')]
        [String]$Name,

        [ValidateRange(2, 1024)]
        [Int32]$LoadOrder = 1024
    )

    begin {
        $content = [XML](Get-Content $Script:ModConfigPath -Raw)
    }

    process {
        if ($LoadOrder -gt @($content.ModsConfigData.activeMods).Count) {
            $predecessorID = @($content.ModsConfigData.activeMods.li)[-1]
        } else {
            $predecessorID = @($content.ModsConfigData.activeMods.li)[($LoadOrder - 1)]
        }
        $content.ModsConfigData.activeMods.SelectSingleNode(('./li[.="{0}"]' -f $predecessorID)).
                                           CreateNavigator().
                                           InsertAfter(('<li>{0}</li>' -f [System.Web.HttpUtility]::HtmlAttributeEncode($ID)))
    }

    end {
        $content.Save($Script:ModConfigPath)
    }
}