function Reset-RWModConfig {
    <#
    .SYNOPSIS
        Resets the mod load list to load Core only.
    .DESCRIPTION
        Ensures only Core is present in the ActiveMods list in ModsConfig.xml.
    #>

     # Disable-RWMod supports this.
     [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
     [CmdletBinding(SupportsShouldProcess)]
     [OutputType([System.Void])]
     param ( )

     Get-RWModConfig | Where-Object { $_.Name -ne 'Core' } | Disable-RWMod
}
