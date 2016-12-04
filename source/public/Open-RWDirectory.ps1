function Open-RWDirectory {
    # .SYNOPSIS
    #   Opens a folder using a tag.
    # .DESCRIPTION
    #   A simple way to open any of the folders used by RimWorld or this module.
    # .INPUTS
    #   System.String
    #   System.Managemenet.Automation.PSObject
    # .OUTPUTS
    #   None
    # .NOTES
    #   Author: Chris Dent
    #
    #   Change log:
    #     11/10/2016 - Chris Dent - Created.

    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    [OutputType([System.Void])]
    param(
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'ByName')]
        [ValidateSet('Game', 'GameMods', 'WorkshopMods', 'UserSettings', 'ModProfiles')]
        [String]$Name,

        [Parameter(ValueFromPipeline = $true, ParameterSetName = 'FromModInformation')]
        [ValidateScript( { $_.PSObject.TypeNames -contains 'Indented.RimWorld.ModInformation' } )]
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