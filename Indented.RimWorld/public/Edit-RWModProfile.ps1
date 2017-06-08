function Edit-RWModProfile {
    <#
    .SYNOPSIS
        Opens a mod profile in a text editor.
    .DESCRIPTION
        Opens a mod profile, by name, in a text editor.
    .INPUTS
        System.String
    .NOTES
        Change log:
            11/10/2016 - Chris Dent - Created.
    #>

    [OutputType([System.Void])]
    param (
        # The mod to load. By default, the "default" profile is opened.
        [Parameter(Position = 1, ParameterSetName = 'ByProfileName')]
        [String]$ProfileName = 'Default'
    )

    $path = Join-Path $Script:ModProfilePath ('{0}.txt' -f $ProfileName)
    if (-not (Test-Path $path)) {
        $null = New-Item $path -ItemType File
    }
    if (Test-Path $path) {
        notepad $path
    }
}