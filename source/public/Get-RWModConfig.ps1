function Get-RWModConfig {
    param(
        [String]$Name
    )

    if (Test-Path $Script:ModConfigPath) {
        $i = 1
        foreach ($mod in ([XML](Get-Content $Script:ModConfigPath -Raw)).ModsConfigData.activeMods.li) {
            $modInformation = Get-RWMod -ID $mod | Add-Member LoadOrder $i -PassThru

            if ([String]::IsNullOrEmpty($Name) -or $Name.IndexOf('*') -gt -1) {
                $modInformation
            } elseif ($modInformation.Name -eq $Name) {
                return $modInformation
            }
            $i++
        }
    }
}