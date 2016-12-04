function Get-RWModConfig {
    # .SYNOPSIS
    #   Get the list of active mods.
    # .DESCRIPTION
    #   Get-RWModConfig reads the activeMods list from ModsConfig.xml.
    # .INPUTS
    #   System.String
    # .OUTPUTS
    #   Indented.RimWorld.ModInformation (System.Management.Automation.PSObject)
    # .NOTES
    #   Author: Chris Dent
    #
    #   Change log:
    #     11/10/2016 - Chris Dent - Created.

    [OutputType([System.Management.Automation.PSObject])]
    param(
        # The name of the mod as seen in RimWorld.
        [String]$Name
    )

    if (Test-Path $Script:ModConfigPath) {
        $i = 1
        foreach ($mod in [System.Xml.Linq.XDocument]::Load($Script:ModConfigPath).Element('ModsConfigData').Element('activeMods').Elements('li').Value) {
            $modInformation = Get-RWMod -ID $mod | Add-Member LoadOrder $i -PassThru

            if ([String]::IsNullOrEmpty($Name) -or $Name.IndexOf('*') -gt -1) {
                $modInformation
            } elseif ($modInformation.Name -eq $Name) {
                return $modInformation
            }
            $i++
        }
    }
}