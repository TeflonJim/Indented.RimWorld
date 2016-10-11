function Get-RWModConfig {
    if (Test-Path $Script:ModConfigPath) {
        $i = 1
        foreach ($mod in ([XML](Get-Content $Script:ModConfigPath -Raw)).ModsConfigData.activeMods.li) {
            Get-RWMod -ID $mod | Select-Object @{n='LoadOrder';e={ $i }}, *
            $i++
        }
    }
}