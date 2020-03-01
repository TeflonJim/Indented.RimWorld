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

    [CmdletBinding(DefaultParameterSetName = 'ByID', SupportsShouldProcess)]
    [OutputType([System.Void])]
    param (
        # The ID of a mod to disable. The ID is the folder name which may match the name of the mod as seen in RimWorld.
        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName, ParameterSetName = 'ByID')]
        [String]$ID,

        # The name of the mod as seen in RimWorld.
        [Parameter(Mandatory, ParameterSetName = 'ByName')]
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
            $rwMod = Get-RWMod -ID $ID

            $supported = $false
            foreach ($version in $rwMod.SupportedVersions) {
                $version = [Version]$version
                if ($version.Major -eq $Script:GameVersion.Major -and $version.Minor -eq $Script:GameVersion.Minor) {
                    $supported = $true

                    Write-Verbose ('Enabling mod {0}' -f $mod)

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
            if (-not $supported) {
                Write-Warning ('Unable to enable mod {0}. Not compatible with RimWorld version {1}.' -f $rwMod.Name, $Script:GameVersion)
            }
        }
    }

    end {
        if ($pscmdlet.ParameterSetName -eq 'ByID') {
            $content.Save($Script:ModConfigPath)
        }
    }
}
