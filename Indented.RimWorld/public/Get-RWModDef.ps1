function Get-RWModDef {
    <#
    .SYNOPSIS
        Get Defs from the mod.
    .DESCRIPTION
        Get the Defs from the mod.

        This function attempts to convert first-level elements from the Def XML to an object. As properties in objects must be unique this function will also flag duplicates.
    .INPUTS
        Indented.RimWorld.ModInformation
    .EXAMPLE
        Get-RWMod SomeMod | Get-RWModDef
    #>

    [CmdletBinding(DefaultParameterSetName = 'ByModName')]
    [OutputType('Indented.RimWorld.DefInformation')]
    param (
        # Get Defs from the specified mod name.
        [Parameter(Mandatory, Position = 1, ParameterSetName = 'ByModName')]
        [String]$ModName,

        # The name of a Def to retrieve.
        [String]$DefName,

        # The def type to find.
        [String]$DefType,

        # An XPath filter to use to search for Defs.
        [string]$XPathQuery = '/Defs/*',

        # Get defs which apply to the specified RimWorld version.
        [version]$Version,

        # Accepts an output pipeline from Get-RWMod.
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'FromModInformation')]
        [PSTypeName('Indented.RimWorld.ModInformation')]
        $ModInformation,

        # Only show warnings
        [Switch]$WarningsOnly
    )

    begin {
        if ($pscmdlet.ParameterSetName -eq 'ByModName') {
            $null = $psboundparameters.Remove('ModName')
            Get-RWMod -Name $ModName | Get-RWModDef @psboundparameters
        }
    }

    process {
        if ($pscmdlet.ParameterSetName -eq 'FromModInformation') {
            $versionedPath = $null
            if ($Version) {
                $versionedPath = Join-Path -Path $ModInformation.Path -ChildPath $Version | Join-Path -ChildPath 'Defs'
            }
            if ($versionedPath -and (Test-Path $versionedPath)) {
                $path = $versionedPath
            }
            else {
                $path = Join-Path -Path $ModInformation.Path -ChildPath 'Defs'
            }

            if (Test-Path $path) {
                Get-ChildItem -Path $path -File -Filter *.xml -Recurse | ForEach-Object {
                    $path = $_.FullName

                    Write-Verbose -Message ('Reading {0}' -f $path)

                    try {
                        $xDocument = [System.Xml.Linq.XDocument]::Load($path)

                        if (-not $psboundparameters.ContainsKey('XPathQuery')) {
                            if ($DefType) {
                                $XPathQuery = '/Defs/{0}' -f $DefType
                            } else {
                                $XPathQuery = '/Defs/*'
                            }
                            if ($DefName) {
                                $XPathQuery = (@(
                                    '({0}[contains(translate(defName, "ABCDEFGHIJKLMNOPQRSTUVWXYZ", "abcdefghijklmnopqrstuvwxyz"), "{1}") or'
                                    'contains(translate(@Name, "ABCDEFGHIJKLMNOPQRSTUVWXYZ", "abcdefghijklmnopqrstuvwxyz"), "{1}")])'
                                ) -join ' ') -f @(
                                    $XPathQuery
                                    $DefName.ToLower()
                                )
                            }
                        }
                        [System.Xml.XPath.Extensions]::XPathSelectElements(
                            $xDocument,
                            $XPathQuery
                        ) | ForEach-Object {
                            if (-not $WarningsOnly) {
                                $def = [PSCustomObject]@{
                                    DefName          = $_.Elements().Where( { $_.Name.ToString() -eq 'defName' } ).Value
                                    DefType          = $_.Name
                                    AppliesToVersion = 'Any'
                                    ID               = ''
                                    ModName          = $ModInformation.Name
                                    Def              = $_ | ConvertFromXElement
                                    Path             = $path
                                    XElement         = $_
                                    IsAbstract       = $false
                                    PSTypeName       = 'Indented.RimWorld.DefInformation'
                                }
                                if ($abstract = $_.Attributes().Where( { $_.Name.LocalName -eq 'Abstract' } )) {
                                    $def.IsAbstract = (Get-Variable $abstract.Value).Value
                                    $def.DefName = $_.Attributes().Where( { $_.Name.LocalName -eq 'Name' }).Value
                                }
                                $def.ID = '{0}\{1}' -f $def.DefType, $def.DefName
                                if ($path -match '\\(\d.\d)\\') {
                                    $def.AppliesToVersion = $matches[1]
                                }

                                $def
                            }
                        }
                    } catch {
                        Write-Warning -Message ('Error loading XML file from {0}\{1} ({2})' -f $ModInformation.Name, $name, $_.Exception.Message)
                    }
                } | Where-Object { $DefName -eq '' -or $_.DefName -like $DefName }
            }
        }
    }
}
