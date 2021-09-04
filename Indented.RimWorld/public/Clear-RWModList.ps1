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

    $modList = [Xml]::new()
    $modList.Load($Script:ModListPath)

    if ($pscmdlet.ShouldProcess(('Removing all mods from the active mods list' -f $PackageID))) {
        if ($modList.ModList.modIds) {
            $modList.ModList.modIds.RemoveAll()
        }
        if ($modList.ModList.modNames) {
            $modList.ModList.modNames.RemoveAll()
        }
    }

    $modList.Save($Script:ModListPath)
}
