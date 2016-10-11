function Clear-RWModConfig {
    Get-RWModConfig | Where-Object { $_.Name -ne 'Core' } | Disable-RWMod
}