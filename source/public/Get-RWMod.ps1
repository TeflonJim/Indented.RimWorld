function Get-RWMod {
    # .SYNOPSIS
    #   Get the mods available to RimWorld.
    # .DESCRIPTION
    #   Get-RWMod searches the games mod path and the workshop mod path for mods.
    # .INPUTS
    #   System.String
    # .OUTPUTS
    #   Indented.RimWorld.ModInformation (System.Management.Automation.PSObject)
    # .NOTES
    #   Author: Chris Dent
    #
    #   Change log:
    #     11/10/2016 - Chris Dent - Created.

    [CmdletBinding(DefaultParameterSetName = 'ByID')]
    [OutputType([System.Management.Automation.PSObject])]
    param(
        # The ID of a mod. The ID is the folder name which may match the name of the mod as seen in RimWorld.
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByID')]
        [String]$ID,

        # The name of the mod as seen in RimWorld.
        [Parameter(Position = 1, ParameterSetName = 'ByName')]
        [String]$Name = '*'
    )

    begin {
        if ($pscmdlet.ParameterSetName -eq 'ByName') {
            if ($Script:ModSearchCache.Contains($Name)) {
                $rwMod = Get-RWMod -ID $Script:ModSearchCache[$Name]
                if ($rwMod) {
                    $rwMod
                } else {
                    # Try and search again if the cache item appears to have become invalid.
                    $Script:ModSearchCache.Remove($Name)
                    Get-RWMod -Name $Name
                }
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
                        Name          = ($xElement.Element('name').Value -replace ' *\(?(\[?[Av]\d+(\.\d+)*\]?[a-z]*\,?)+\)?').Trim().Trim('_-')
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
                    $regex = '(?:v(?:ersion:?)? *)?((?:\d+\.){1,}\d+)'
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