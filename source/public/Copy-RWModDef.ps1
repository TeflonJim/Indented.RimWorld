function Copy-RWModDef {
    # .SYNOPSIS
    #   Copies a definition from a mod.
    # .DESCRIPTION
    # 

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String]$Name,
    
        [String]$DefType = '*Defs*',

        [String]$NewName,

        [String[]]$Remove,

        [Hashtable]$Update,

        [ValidateScript( { Test-Path $_ -PathType Leaf } )]
        [String]$SaveAs
    )

    $modName, $defName = $Name -split '[\\/]'
    if ($null -eq $modName) {
        $modName = 'Core'
    }

    if ($null -eq $Script:defCopyCache) {
        $Script:defCopyCache = @{}
    }
    if ($Script:defCopyCache.Contains($Name)) {
        $def = $Script:defCopyCache[$Name]
    } else {
        $def = Get-RWModDef -ModName $modName -DefType $DefType -DefName $defName | ForEach-Object { $_.XElement.ToString() }
        # Store as a string to disassociate the new instance from anything in the cache.
        $Script:defCopyCache.Add($Name, $def)
    }

    if ($null -eq $def) {
        $errorRecord = New-Object System.Management.Automation.ErrorRecord(
            (New-Object System.ArgumentException('Cannot locate source def')),
            'UnknownDef',
            [System.Management.Automation.ErrorCategory]::InvalidArgument,
            ('{0}\{1}' -f $modName, $defName)
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
                            New-Object System.Xml.Linq.XElement(
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
                            New-Object System.Xml.Linq.XElement(
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