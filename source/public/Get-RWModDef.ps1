function Get-RWModDef {
    # .SYNOPSIS
    #   Get Defs from the mod.
    # .DESCRIPTION
    #   Get the Defs from the mod.
    #
    #   This function attempts to convert first-level elements from the Def XML to an object. As properties in objects must be unique this function will also flag duplicates.
    # .PARAMETER ModName
    #   Get Defs from the specified mod name.
    # .PARAMETER ModInformation
    #   Accepts an output pipeline from Get-RWMod.
    # .INPUTS
    #   Indented.RimWorld.Mod
    #   System.String
    # .OUTPUTS
    #   Indented.RimWorld.Def
    # .EXAMPLE
    #   Get-RWMod SomeMod | Get-RWModDef
    # .NOTES
    #   Author: Chris Dent
    #   Last modified: 15/06/2014
    #
    #   Change log:
    #     15/06/2014 - Created

    [CmdletBinding(DefaultParameterSetName = 'ByModName')]
    param(
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'ByModName')]
        [ValidateNotNullOrEmpty()]
        [String]$ModName,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'FromModInformation')]
        [ValidateScript( { $_.PSObject.TypeNames -contains 'Indented.RimWorld.ModInformation' } )]
        $ModInformation,

        [Switch]$WarningsOnly
    )

    begin {
        if ($pscmdlet.ParameterSetName -eq 'ByModName') {
            Get-RWMod -Name $ModName | Get-RWModDef
        }
    }

    process {
        if ($pscmdlet.ParameterSetName -eq 'FromModInformation') {
            $defsPath = Join-Path $ModInformation.Path 'Defs'
            if ([System.IO.Directory]::Exists($defsPath)) {
                Get-ChildItem -LiteralPath $defsPath -Filter *.xml -Recurse | ForEach-Object {
                    $path = $_.FullName
                    $name = $_.Name

                    Write-Verbose -Message ('Reading {0}' -f $path)

                    try {
                        $xDocument = [System.Xml.Linq.XDocument]::Load($path)
                        foreach ($xElement in $xDocument.Elements()) {
                            foreach ($defXElement in $xElement.Elements()) {
                                if ($defXElement.Element('defName').Value) {
                                    [PSCustomObject]@{
                                        DefName          = $defXElement.Element('defName').Value
                                        DefType          = $defXElement.Name
                                        ID               = '{0}\{1}' -f $defXElement.Name, $defXElement.Element('defName').Value
                                        ModName          = $ModInformation.Name
                                        Def              = $defXElement | ConvertFromXElement
                                        DefContainerType = $xElement.Name
                                        Path             = $_.FullName
                                    } | Add-Member -TypeName 'Indented.RimWorld.DefInformation' -PassThru
                                }
                            }
                        }
                    } catch {
                        Write-Warning -Message ('Error loading XML file from {0}\{1} ({2})' -f $ModInformation.Name, $name, $_.Exception.Message)
                    }
                }
            }
        }
    }
}