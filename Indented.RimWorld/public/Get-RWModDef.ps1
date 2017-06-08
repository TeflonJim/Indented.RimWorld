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
    .NOTES
        Change log:
            15/06/2014 - Chris Dent - Created
    #>

    [CmdletBinding(DefaultParameterSetName = 'ByModName')]
    [OutputType('Indented.RimWorld.DefInformation')]
    param (
        # Get Defs from the specified mod name.
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'ByModName')]
        [String]$ModName,

        # The name of a Def to retrieve.
        [String]$DefName,

        # The type of definition to search for.
        [String]$DefType = '*Defs*',

        # Accepts an output pipeline from Get-RWMod.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'FromModInformation')]
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
        if ($DefType -notmatch 'Defs') {
            $DefType = '{0}Defs*' -f $DefType
        }
    }

    process {
        if ($pscmdlet.ParameterSetName -eq 'FromModInformation') {
            $defsPath = Join-Path $ModInformation.Path 'Defs'
            if ([System.IO.Directory]::Exists($defsPath)) {
                Get-ChildItem -LiteralPath $defsPath -Directory -Filter $DefType | ForEach-Object {
                    Get-ChildItem -LiteralPath $_.FullName -File -Filter *.xml | ForEach-Object {
                        $path = $_.FullName
                        $name = $_.Name

                        Write-Verbose -Message ('Reading {0}' -f $path)

                        try {
                            $xDocument = [System.Xml.Linq.XDocument]::Load($path)
                            foreach ($xElement in $xDocument.Elements()) {
                                foreach ($defXElement in $xElement.Elements()) {
                                    if (-not $WarningsOnly) {
                                        $def = [PSCustomObject]@{
                                            DefName          = $defXElement.Elements().Where( { $_.Name.ToString() -eq 'defName' } ).Value
                                            DefType          = $defXElement.Name
                                            ID               = ''
                                            ModName          = $ModInformation.Name
                                            Def              = $defXElement | ConvertFromXElement
                                            DefContainerType = $xElement.Name
                                            Path             = $_.FullName
                                            XElement         = $defXElement
                                            IsAbstract       = $false
                                        } | Add-Member -TypeName 'Indented.RimWorld.DefInformation' -PassThru
                                        if ($abstract = $defXElement.Attributes().Where( { $_.Name.LocalName -eq 'Abstract' } )) {
                                            $def.IsAbstract = (Get-Variable $abstract.Value).Value
                                            $def.DefName = $defXElement.Attributes().Where( { $_.Name.LocalName -eq 'Name' }).Value
                                        }
                                        $def.ID = '{0}\{1}' -f $def.DefType, $def.DefName

                                        $def
                                    }
                                }
                            }
                        } catch {
                            Write-Warning -Message ('Error loading XML file from {0}\{1} ({2})' -f $ModInformation.Name, $name, $_.Exception.Message)
                        }
                    }
                } | Where-Object { $DefName -eq '' -or $_.DefName -like $DefName }
            }
        }
    }
}