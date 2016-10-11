function ConvertFromXElement {
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