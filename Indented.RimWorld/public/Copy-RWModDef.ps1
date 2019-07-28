function Copy-RWModDef {
    <#
    .SYNOPSIS
        Copies a definition from a mod.
    .DESCRIPTION
        Copies a definition from a mod.
    #>

    [CmdletBinding()]
    [OutputType([System.Xml.Linq.XDocument])]
    param (
        [Parameter(Mandatory = $true)]
        [String]$Name,

        [String]$DefType,

        [String]$NewName,

        [String[]]$Remove,

        [Hashtable]$Update,

        [ValidateScript( { Test-Path $_ -PathType Leaf } )]
        [String]$SaveAs
    )

    $id = $Name
    if ($DefType) {
        $id = '{0}\{1}' -f $Name, $DefType
    }

    $modName, $defName = $Name -split '[\\/]'
    if ($null -eq $modName) {
        $modName = 'Core'
    }

    if ($null -eq $Script:defCopyCache) {
        $Script:defCopyCache = @{}
    }
    if ($Script:defCopyCache.Contains($id)) {
        $def = $Script:defCopyCache[$id]
    } else {
        $params = @{
            ModName = $modName
            DefName = $defName
        }
        if ($DefType) {
            $params.DefType = $DefType
        }
        $def = Get-RWModDef @params | ForEach-Object { $_.XElement.ToString() }
        $Script:defCopyCache.Add($id, $def)
    }

    if ($null -eq $def) {
        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
            [ArgumentException]::new('Cannot locate source def'),
            'UnknownDef',
            [System.Management.Automation.ErrorCategory]::InvalidArgument,
            $id
        )
        $pscmdlet.ThrowTerminatingError($errorRecord)
    }

    $def = [System.Xml.Linq.XDocument]::Parse($def)

    if ($NewName) {
        if ($def.Root.Element('DefName')) {
            $def.Root.Element('DefName').SetValue($NewName)
        } elseif ($def.Root.Element('defName')) {
            $def.Root.Element('defName').SetValue($NewName)
        } elseif ($def.Root.Attribute('Name')) {
            $def.Root.Attribute('Name').SetValue($NewName)
        }
    }

    if ($psboundparameters.ContainsKey('Remove')) {
        foreach ($item in $Remove) {
            $xElement = $def.FirstNode
            foreach($element in $item.Split('.')) {
                if ($xElement) {
                    $xElement = $xElement.Element($element)
                }
            }
            if  ($xElement) {
                $xElement.Remove()
            }
        }
    }

    if ($psboundparameters.ContainsKey('Update')) {
        foreach ($item in $Update.Keys) {
            $xElement = $def.FirstNode
            foreach ($element in $item.Split('.')) {
                $childXElement = $xElement.Element($element)
                if ($null -eq $childXElement) {
                    if ($xElement.Name -eq 'comps') {
                        $xElement = $xElement.Elements().Where( { $_.Attribute('Class').Value -eq $element } )
                    } elseif ($childAttribute = $xElement.Attribute($element)) {
                        $xElement = $childAttribute
                    } else {
                        $xElement.Add((
                            [System.Xml.Linq.XElement]::new(
                                [System.Xml.Linq.XName]$element,
                                $null
                            )
                        ))
                        $xElement = $xElement.Element($element)
                    }
                } else {
                    $xElement = $childXElement
                }
            }
            if  ($xElement) {
                if ($Update[$item] -is [Array]) {
                    foreach ($value in $Update[$item]) {
                        $xElement.Add((
                            [System.Xml.Linq.XElement]::new(
                                [System.Xml.Linq.XName]'li',
                                $value
                            )
                        ))
                    }
                } else {
                    $xElement.SetValue($Update[$item])
                }
            }
        }
    }

    if ($SaveAs) {
        $xDocument = [System.Xml.Linq.XDocument]::Load($SaveAs)
        $xDocument.Root.Add($def.Root)

        $xDocument.Save($SaveAs)
    } else {
        $def
    }
}