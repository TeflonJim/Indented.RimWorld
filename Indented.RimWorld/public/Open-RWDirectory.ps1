function Open-RWDirectory {
    <#
    .SYNOPSIS
        Opens a folder using a tag.
    .DESCRIPTION
        A simple way to open any of the folders used by RimWorld or this module.
    .INPUTS
        System.String
    .NOTES
        Change log:
            11/10/2016 - Chris Dent - Created.
    #>

    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    [OutputType([System.Void])]
    param (
        # The name, or tag, of the directory to open.
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'ByName')]
        [ValidateSet('Game', 'GameMods', 'WorkshopMods', 'UserSettings', 'ModProfiles')]
        [String]$Name,

        # Open a directory for an existing mod.
        [Parameter(ValueFromPipeline = $true, ParameterSetName = 'FromModInformation')]
        [PSTypeName('Indented.RimWorld.ModInformation')]
        [PSObject]$ModInformation
    )

    begin {
        if ($pscmdlet.ParameterSetName -eq 'ByName') {
            switch ($Name) {
                'Game'         { Invoke-Item $Script:GamePath; break }
                'GameMods'     { Invoke-Item $Script:GameModPath; break }
                'WorkshopMods' { Invoke-Item $Script:WorkshopModPath; break }
                'UserSettings' { Invoke-Item $Script:UserSettings; break }
                'ModProfiles'  { Invoke-Item $Script:ModProfilePath; break }
            }
        }
    }

    process {
        if ($pscmdlet.ParameterSetName -eq 'FromModInformation') {
            Invoke-Item $ModInformation.Path
        }
    }
}