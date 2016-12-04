function Get-RWModProfile {
    param(
        [Parameter(Position = 1, ParameterSetName = 'ByProfileName')]
        [String]$ProfileName = '*'
    )

    Get-ChildItem $Script:ModProfilePath -Filter ('{0}.txt' -f $ProfileName) | ForEach-Object {
        $modProfile = Get-Content $_.FullName -Raw
        $modList = foreach ($mod in $modProfile.Split("`r`n", [System.StringSplitOptions]::RemoveEmptyEntries)) {
            $mod = $mod.Trim()
            if ($mod -and -not $mod.StartsWith('#')) {
                $rwMod = Get-RWMod -Name $mod
                if ($rwMod) {
                    $rwMod
                }
            }
        }
        [PSCustomObject]@{
            ProfileName = $_.BaseName
            ModList     = $modList
        }
    }
}