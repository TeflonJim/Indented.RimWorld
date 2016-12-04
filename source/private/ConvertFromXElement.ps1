function ConvertFromXElement {
    # .SYNOPSIS
    #   Internal use only.
    # .DESCRIPTION
    #   Offload conversion of an XElement to a PSObject.
    # .INPUTS
    #   System.Xml.Linq.XElement
    # .OUTPUTS
    #   System.Management.Automation.PSObject
    # .NOTES
    #   Author: Chris Dent
    #
    #   Change log:
    #     11/10/2016 - Chris Dent - Created.
    
    param(
        [Parameter(ValueFromPipeline = $true)]
        [System.Xml.Linq.XElement]$XElement
    )

    process {
        if ($xElement.HasElements) {
            $psObject = New-Object PSObject
            foreach ($childXElement in $xElement.Elements()) {
                if ($childXElement.Name -eq 'li') {
                    if ($childXElement.HasElements) {
                        ConvertFromXElement $childXElement
                    } else {
                        $childXElement.Value
                    }
                } else {
                    if ($childXElement.HasElements) {
                        $psObject | Add-Member $childXElement.Name ($childXElement | ConvertFromXElement) -Force
                    } else {
                        $psObject | Add-Member $childXElement.Name $childXElement.Value -Force
                    }
                }
            }
            $psObject
        } else {
            $xElement.Value
        }
    }
}