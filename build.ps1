param (
    [string[]]$TaskName = ('Clean', 'Build', 'UpdateLocal')
)

function Clean {
    $path = Join-Path -Path $PSScriptRoot -ChildPath 'build'
    if (Test-Path $path) {
        Remove-Item $path -Recurse
    }
}

function Build {
    Build-Module -Path (Resolve-Path $PSScriptRoot\*\build.psd1) -Verbose
}

function UpdateLocal {
    $source = Join-Path -Path $PSScriptRoot -ChildPath 'build\*\*\*.psd1' |
        Get-Item |
        Where-Object { $_.BaseName -eq $_.Directory.Parent.Name } |
        Select-Object -ExpandProperty Directory

    $destination = Join-Path -Path ([Environment]::GetFolderPath('MyDocuments')) -ChildPath 'PowerShell\Modules' |
        Join-Path -ChildPath $source.Parent.Name

    if (-not (Test-Path $destination)) {
        $null = New-Item -Path $destination -ItemType Directory
    }

    Copy-Item -Path $source.FullName -Destination $destination -Recurse -Force
}

function WriteMessage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Message,

        [ValidateSet('Information', 'Warning', 'Error')]
        [string]$Category = 'Information',

        [string]$Details
    )

    $params = @{
        Object          = ('{0}: {1}' -f $Message, $Details).TrimEnd(' :')
        ForegroundColor = switch ($Category) {
            'Information' { 'Cyan' }
            'Warning' { 'Yellow' }
            'Error' { 'Red' }
        }
    }
    Write-Host @params

    if ($env:APPVEYOR_JOB_ID) {
        Add-AppveyorMessage @PSBoundParameters
    }
}

function InvokeTask {
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$TaskName
    )

    begin {
        Write-Host ('Build {0}' -f $PSCommandPath) -ForegroundColor Green
    }

    process {
        $ErrorActionPreference = 'Stop'
        try {
            $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

            WriteMessage -Message ('Task {0}' -f $TaskName)
            & "Script:$TaskName"
            WriteMessage -Message ('Done {0} {1}' -f $TaskName, $stopWatch.Elapsed)
        } catch {
            WriteMessage -Message ('Failed {0} {1}' -f $TaskName, $stopWatch.Elapsed) -Category Error -Details $_.Exception.Message

            exit 1
        } finally {
            $stopWatch.Stop()
        }
    }
}

$TaskName | InvokeTask
