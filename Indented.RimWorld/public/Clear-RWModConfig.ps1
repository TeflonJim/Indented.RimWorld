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

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')] # Disable-RWMod supports this.
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([System.Void])]
    param ( )

    Get-RWModConfig | Where-Object { $_.Name -ne 'Core' } | Disable-RWMod
}