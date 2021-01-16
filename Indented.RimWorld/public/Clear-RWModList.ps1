function Clear-RWModList {
    <#
    .SYNOPSIS
        Clears the mod load list.
    .DESCRIPTION
        Clears all mods from the mod list.
    #>

     # Disable-RWMod supports this.
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param ( )

    Get-RWModList | Disable-RWMod
}
