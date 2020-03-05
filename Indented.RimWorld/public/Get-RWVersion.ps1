function Get-RWVersion {
    [CmdletBinding()]
    param ( )

    $path = Join-Path -Path $Script:GamePath -ChildPath 'version.txt'

    if (Test-Path $path) {
        $versionData = Get-Content -Path $path -Raw
        [Version]$version, $revision = $versionData -split ' rev'

        [PSCustomObject]@{
            Version      = [Version]::new($version.Major, $version.Minor, $version.Build, $revision)
            ShortVersion = [Version]::new($version.Major, $version.Minor)
        }
    }
}
