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

        # The PackageId of a mod.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ByPackageID')]
        [String]$PackageID,

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

        if ($pscmdlet.ParameterSetName -eq 'ByPackageID') {
            if ($Script:ModPackageIdCache.Contains($PackageID)) {
                $rwMod = Get-RWMod -ID $Script:ModPackageIdCache[$PackageID]
                if ($rwMod) {
                    $rwMod
                } else {
                    # Try and search again if the cache item appears to have become invalid.
                    $Script:ModPackageIdCache.Remove($PackageID)
                    Get-RWMod -Name $Name
                }
            } else {
                Get-RWMod | Where-Object { $_.PackageID -like $PackageID -or $_.PackageID -eq $PackageID }
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
                    $aboutPath = Join-Path -Path $modPath -ChildPath 'About\about.xml'
                    # Test-Path doesn't get on well with some special characters and has no literal path parameter.
                    if (Test-Path -Path $aboutPath) {
                        try {
                            $xmlDocument = [Xml](Get-Content -Path $aboutPath -Raw)
                            $xmlNode = $xmlDocument.ModMetadata

                            if ($xmlNode.SelectSingleNode('/*/name')) {
                                $modName = $xmlNode.name -replace ' *\(?(\[?[ABv]?\d+(\.\d+)*\]?[a-z]*\,?)+\)?' -replace '^[ \]]+|[ \[-]+$'
                            } else {
                                $modName = $ID
                            }

                            $modMetadata = [PSCustomObject]@{
                                Name              = $modName
                                RawName           = $xmlNode.name
                                ID                = $ID
                                PackageID         = $xmlNode.packageID
                                Version           = $xmlNode.version
                                Author            = $xmlNode.author
                                Description       = $xmlNode.description
                                URL               = $xmlNode.url
                                SupportedVersions = $xmlNode.targetVersion
                                LoadAfter         = $xmlNode.loadAfter.li
                                LoadBefore        = $xmlNode.loadBefore.li
                                IncompatibleWith  = $xmlNode.incompatibleWith.li
                                Dependencies      = $xmlNode.modDependencies.li.packageID
                                Path              = $modPath
                                PSTypeName        = 'Indented.RimWorld.ModInformation'
                            }
                            if ($xmlNode.SupportedVersions) {
                                $modMetadata.SupportedVersions = $xmlNode.SupportedVersions.li
                            }
                            foreach ($property in 'ID', 'PackageID', 'LoadAfter', 'LoadBefore', 'Dependencies') {
                                $modMetadata.$property = foreach ($value in $modMetadata.$property) {
                                    $value.ToLower()
                                }
                            }

                            # Best effort version parser
                            $manifestPath = Join-Path -Path $modPath -ChildPath 'About\Manifest.xml'
                            if (Test-Path -Path $manifestPath) {
                                $xmlDocument = [Xml](Get-Content -Path $manifestPath -Raw)
                                $modMetadata.Version = $xmlDocument.Manifest.version
                            } else {
                                $regex = '(?:v(?:ersion:?)? *)?((?:\d+\.){1,}\d+)'
                                if ($modMetadata.RawName -match $regex -or $modMetadata.Description -match $regex) {
                                    $modMetadata.Version = $matches[1]
                                }
                            }

                            if (-not $Script:ModSearchCache.Contains($modMetadata.Name)) {
                                $Script:ModSearchCache.Add($modMetadata.Name, $ID)
                            }
                            if ($modMetadata.PackageID -and -not $Script:ModPackageIdCache.Contains($modMetadata.PackageID)) {
                                $Script:ModPackageIdCache.Add($modMetadata.PackageID, $ID)
                            }

                            $modMetadata
                        } catch {
                            Write-Error ('Error reading {0}: {1}' -f $aboutPath, $_.Exception.Message.Trim())
                        }
                    }
                }
            } else {
                foreach ($path in $Script:GameExpansionPath, $Script:GameModPath, $Script:WorkshopModPath) {
                    Get-ChildItem -Path $path -Directory | Get-RWMod -ID { $_.Name }
                }
            }
        }
    }
}
