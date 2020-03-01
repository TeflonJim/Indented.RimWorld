function Get-RWMod {
    <#
    .SYNOPSIS
        Get the mods available to RimWorld.
    .DESCRIPTION
        Get-RWMod searches the games mod path and the workshop mod path for mods.
    .INPUTS
        System.String
    .NOTES
        Change log:
            11/10/2016 - Chris Dent - Created.
    #>

    [CmdletBinding(DefaultParameterSetName = 'ByID')]
    [OutputType('Indented.RimWorld.ModInformation')]
    param (
        # The ID of a mod. The ID is the folder name which may match the name of the mod as seen in RimWorld.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ByID')]
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
                Get-RWMod | Where-Object { $_.Name -like $Name -or $_.Name -eq $Name }
            }
        }
    }

    process {
        if ($pscmdlet.ParameterSetName -eq 'ByID') {
            if ($psboundparameters.ContainsKey('ID')) {
                if ([Int32]::TryParse($ID, [Ref]$null)) {
                    $modPaths = Join-Path $Script:WorkshopModPath $ID
                } else {
                    $modPaths = $Script:GameExpansionPath, $Script:GameModPath |
                        Join-Path -ChildPath { $ID }
                }

                foreach ($modPath in $modPaths) {
                    $aboutPath = Join-Path $modPath 'About\about.xml'
                    # Test-Path doesn't get on well with some special characters and has no literal path parameter.
                    if ([System.IO.File]::Exists($aboutPath)) {
                        try {
                            $xmlDocument = [Xml](Get-Content $aboutPath -Raw)
                            $xmlNode = $xmlDocument.ModMetaData

                            if ($xmlNode.SelectSingleNode('/*/name')) {
                                $modName = ($xmlNode.name -replace ' *\(?(\[?[ABv]?\d+(\.\d+)*\]?[a-z]*\,?)+\)?').Trim(' _-')
                            } else {
                                $modName = $ID
                            }

                            $modMetaData = [PSCustomObject]@{
                                Name              = $modName
                                RawName           = $xmlNode.name
                                ID                = $ID
                                Version           = $xmlNode.version
                                Author            = $xmlNode.author
                                Description       = $xmlNode.description
                                URL               = $xmlNode.url
                                SupportedVersions = $xmlNode.targetVersion
                                Path              = $modPath
                                PSTypeName        = 'Indented.RimWorld.ModInformation'
                            }
                            if ($xmlNode.SupportedVersions) {
                                $modMetaData.SupportedVersions = $xmlNode.SupportedVersions.li
                            }

                            # Best effort version parser
                            $regex = '(?:v(?:ersion:?)? *)?((?:\d+\.){1,}\d+)'
                            if ($modMetaData.Name -match $regex -or $modMetaData.Description -match $regex) {
                                $modMetaData.Version = $matches[1]
                            }
                            if (-not $Script:ModSearchCache.Contains($modMetaData.Name)) {
                                $Script:ModSearchCache.Add($modMetaData.Name, $ID)
                            }

                            $modMetaData
                        } catch {
                            Write-Error ('Error reading {0}: {1}' -f $aboutPath, $_.Exception.Message.Trim())
                        }
                    }
                }
            } else {
                foreach ($path in $Script:GameExpansionPath, $Script:GameModPath, $Script:WorkshopModPath) {
                    Get-ChildItem $path -Directory | Get-RWMod -ID { $_.Name }
                }
            }
        }
    }
}
