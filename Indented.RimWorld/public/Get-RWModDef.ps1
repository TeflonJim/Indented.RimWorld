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
            $defsPath = Join-Path $ModInformation.Path 'Defs'
            if ([System.IO.Directory]::Exists($defsPath)) {
                Get-ChildItem -LiteralPath $defsPath -File -Filter *.xml -Recurse | ForEach-Object {
                    $path = $_.FullName
                    $name = $_.Name

                    Write-Verbose -Message ('Reading {0}' -f $path)

                    try {
                        $xDocument = [System.Xml.Linq.XDocument]::Load($path)
                        if ($DefType) {
                            $xpathQuery = '/Defs/{0}' -f $DefType
                        } else {
                            $xpathQuery = '/Defs/*'
                        }
                        if ($DefName) {
                            $xpathQuery = (@(
                                '({0}[contains(translate(defName, "ABCDEFGHIJKLMNOPQRSTUVWXYZ", "abcdefghijklmnopqrstuvwxyz"), "{1}") or'
                                'contains(translate(@Name, "ABCDEFGHIJKLMNOPQRSTUVWXYZ", "abcdefghijklmnopqrstuvwxyz"), "{1}")])'
                            ) -join ' ') -f @(
                                $xPathQuery
                                $DefName.ToLower()
                            )
                        }
                        [System.Xml.XPath.Extensions]::XPathSelectElements(
                            $xDocument,
                            $xpathQuery
                        ) | ForEach-Object {
                            if (-not $WarningsOnly) {
                                $def = [PSCustomObject]@{
                                    DefName    = $_.Elements().Where( { $_.Name.ToString() -eq 'defName' } ).Value
                                    DefType    = $_.Name
                                    ID         = ''
                                    ModName    = $ModInformation.Name
                                    Def        = $_ | ConvertFromXElement
                                    Path       = $path
                                    XElement   = $_
                                    IsAbstract = $false
                                    PSTypeName = 'Indented.RimWorld.DefInformation'
                                }
                                if ($abstract = $_.Attributes().Where( { $_.Name.LocalName -eq 'Abstract' } )) {
                                    $def.IsAbstract = (Get-Variable $abstract.Value).Value
                                    $def.DefName = $_.Attributes().Where( { $_.Name.LocalName -eq 'Name' }).Value
                                }
                                $def.ID = '{0}\{1}' -f $def.DefType, $def.DefName

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
