function Get-RWMod {
    [CmdletBinding(DefaultParameterSetName = 'ByID')]
    param(
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByID')]
        [String]$ID,

        [Parameter(Position = 1, ParameterSetName = 'ByName')]
        [String]$Name = '*'
    )

    begin {
        if ($pscmdlet.ParameterSetName -eq 'ByName') {
            if ($Script:ModSearchCache.Contains($Name)) {
                Get-RWMod -ID $Script:ModSearchCache[$Name]
            } else {
                Get-RWMod | Where-Object { $_.Name -like $Name }
            }
        }
    }

    process {
        if ($pscmdlet.ParameterSetName -eq 'ByID') {
            if ($psboundparameters.ContainsKey('ID')) {
                if ([Int32]::TryParse($ID, [Ref]$null)) {
                    $modPath = Join-Path $Script:WorkshopModPath $ID
                } else {
                    $modPath = Join-Path $Script:GameModPath $ID
                }
                $aboutPath = Join-Path $modPath 'About\about.xml'
                # Test-Path doesn't get on well with some special characters and has no literal path parameter.
                if ([System.IO.File]::Exists($aboutPath)) {
                    $modMetaData = ([XML](Get-Item -LiteralPath $aboutPath | Get-Content -Raw)).ModMetaData |
                        Select-Object @{n='Name';e={ ($_.Name -replace ' *\(?([Av]\d+(\.\d+)*[a-z]*\,?)+\)?').Trim() }},
                                      @{n='RawName';e={ $_.Name }},
                                      @{n='ID';e={ $ID }},
                                      Version,
                                      Author,
                                      Description,
                                      URL,
                                      TargetVersion,
                                      @{n='Path';e={ $modPath }} |
                        Add-Member -TypeName 'Indented.RimWorld.ModInformation' -PassThru

                    $regex = 'v(?:ersion:?)? *((?:\d+\.){1,}\d+)'
                    if ($modMetaData.Name -match $regex -or $modMetaData.Description -match $regex) {
                        $modMetaData.Version = $matches[1]
                    }
                    if (-not $Script:ModSearchCache.Contains($modMetaData.Name)) {
                        $Script:ModSearchCache.Add($modMetaData.Name, $ID)
                    }

                    $modMetaData
                }
            } else {
                foreach ($path in ($Script:GameModPath, $Script:WorkshopModPath)) {
                    Get-ChildItem $path -Directory | Get-RWMod -ID { $_.Name }
                }
            }
        }
    }
}