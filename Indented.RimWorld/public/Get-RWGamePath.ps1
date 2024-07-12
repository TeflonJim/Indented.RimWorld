function Get-RWGamePath {
    <#
    .SYNOPSIS
        Get the path to RimWorld.
    .DESCRIPTION
        The path to the RimWorld game is used to discover the mods installed into the games directory.
    #>
    
    [CmdletBinding()]
    [OutputType([string])]
    param ( )

    $Script:GamePath
}