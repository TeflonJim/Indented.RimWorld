function Compare-RWModProfile {
    <#
    .SYNOPSIS
        Shows an overview of the mods across each profile.
    .DESCRIPTION
        Gets the list of all available mods then shows if a mod is used by a mod profile.
    .NOTES
        Change log:
            04/12/2016 - Chris Dent - Created.
    #>

    [OutputType('Indented.RimWorld.ModProfileEntry')]
    param ( )

    if (Test-Path $Script:ModProfilePath\*) {
        $mods = New-Object System.Collections.Generic.Dictionary'[String,PSObject]'
        Get-RWMod | Sort-Object Name | ForEach-Object {
            $mods.Add(
                $_.RawName,
                ([PSCustomObject]@{ Name = $_.RawName } | Add-Member -TypeName 'Indented.RimWorld.ModProfileEntry' -PassThru)
            )
        }

        $allProfileNames = New-Object System.Collections.Generic.List[String]
        Get-RWModProfile | ForEach-Object {
            $allProfileNames.Add($_.ProfileName)
            $i = 0
            foreach ($mod in $_.ModList) {
                Add-Member $_.ProfileName $i -InputObject $mods.($mod.RawName)
                $i++
            }
        }

        # Normalise
        foreach ($value in $mods.Values) {
            foreach ($profileName in $allProfileNames) {
                if ($null -eq ($value.PSObject.Properties.Item($profileName))) {
                    Add-Member $profileName $null -InputObject $value
                }
            }
        }

        $mods.Values
    } else {
        Write-Warning 'No mod profiles have been configured.'
    }
}