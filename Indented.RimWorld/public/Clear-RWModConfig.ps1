﻿function Clear-RWModConfig {
    <#
    .SYNOPSIS
        Clears the mod load list.
    .DESCRIPTION
        Clears all mods except Core from the ActiveMods list in ModsConfig.xml.
    .NOTES
        Change log:
            11/10/2016 - Chris Dent - Created.
    #>

     # Disable-RWMod supports this.
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Void])]
    param ( )

    Get-RWModConfig | Disable-RWMod
}
