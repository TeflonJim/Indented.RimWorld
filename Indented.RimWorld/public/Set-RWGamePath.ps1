function Set-RWGamePath {
    <#
    .SYNOPSIS
        Set the path to RimWorld if it cannot be discovered.
    .DESCRIPTION
        The path to the RimWorld game is used to discover the mods installed into the games directory.
    .NOTES
        Change log:
            21/12/2016 - Chris Dent - Created.
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')] # All commands used by this support ShouldProcess.
    [CmdletBinding()]
    param (
        # The path to the game.
        [ValidateScript( { Test-Path $_ -PathType Container } )]
        [String]$Path
    )

    if (-not (Test-Path (Split-Path $Script:ModuleConfigPath -Parent))) {
        $null = New-Item (Split-Path $Script:ModuleConfigPath -Parent) -ItemType Directory
    }
    [PSCustomObject]@{
        GamePath = $Path
    } | ConvertTo-Json | Out-File $Script:ModuleConfigPath -Encoding utf8
}