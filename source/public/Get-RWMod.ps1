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
                    $xElement = [System.Xml.Linq.XDocument]::Load($aboutPath).Element('ModMetaData')
                    $modMetaData = [PSCustomObject]@{
                        Name          = ($xElement.Element('name').Value -replace ' *\(?([Av]\d+(\.\d+)*[a-z]*\,?)+\)?').Trim()
                        RawName       = $xElement.Element('name').Value
                        ID            = $ID
                        Version       = $xElement.Element('version').Value
                        Author        = $xElement.Element('author').Value
                        Description   = $xElement.Element('description').Value
                        URL           = $xElement.Element('url').Value
                        TargetVersion = $xElement.Element('targetVersion').Value
                        Path          = $modPath
                    } | Add-Member -TypeName 'Indented.RimWorld.ModInformation' -PassThru

                    # Best effort version parser
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