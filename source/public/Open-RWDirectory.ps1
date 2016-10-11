function Open-RWDirectory {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param(
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'ByName')]
        [ValidateSet('Game', 'GameMods', 'WorkshopMods', 'UserSettings')]
        [String]$Name,

        [Parameter(ValueFromPipeline = $true, ParameterSetName = 'FromMod')]
        [PSObject]$Mod
    )

    begin {
        if ($pscmdlet.ParameterSetName -eq 'ByName') {
            switch ($Name) {
                'Game'         { Start-Process $Script:GamePath; break }
                'GameMods'     { Start-Process $Script:GameModPath; break }
                'WorkshopMods' { Start-Process $Script:WorkshopModPath; break }
                'UserSettings' { Start-Process $Script:UserSettings; break }
            }
        }
    }

    process {
        if ($pscmdlet.ParameterSetName -eq 'FromMod') {
            Start-Process $Mod.Path
        }
    }
}