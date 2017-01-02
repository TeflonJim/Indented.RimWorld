function Compare-RWModDef {
    # .SYNOPSIS
    #   Compares Defs across mods.
    # .DESCRIPTION
    #   Compare-RWModDef shows conflicting defNames across RimWorld mods.
    # .INPUTS
    #   Indented.RimWorld.Mod
    #   System.String
    # .OUTPUTS
    #   Indented.RimWorld.DefConflict
    # .EXAMPLE
    #   Compare-RWModDef SomeMod
    #
    #   Compare the Defs from SomeMod with all mods in the Mods directory.
    # .EXAMPLE
    #   Compare-RWModDef SomeMod -ObjectModName OtherMod
    # 
    #   Compare the Defs from SomeMod with the Defs from OtherMod
    # .EXAMPLE
    #   Compare-RWModDef SomeMod -ObjectModName Core -IncludeCore
    #
    #   Show the Defs from SomeMod which override the Defs in Core.
    # .NOTES
    #   Author: Chris Dent
    #
    #   Change log:
    #     15/06/2014 - Created

    [CmdletBinding(DefaultParameterSetName = 'ByModName')]
    [OutputType([System.Management.Automation.PSObject])]
    param(
        # The mod to test.
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'ByModName')]
        [String]$SubjectModName,

        # The mod to compare with. If no mod name is supplied the subject is compared with all mods.
        [Parameter(Position = 2, ParameterSetName = 'ByModName')]
        [Parameter(ParameterSetName = 'FromModInformation')]
        [String]$ObjectModName = "*",

        # Accepts an output pipeline from Get-RWMod.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'FromModInformation')]
        [PSTypeName('Indented.RimWorld.ModInformation')]
        $SubjectModInformation,

        # By default Core is excluded from the comparison; overriding core is expected behaviour. Conflicts with Core can be displayed using this parameter.
        [Switch]$IncludeCore,

        # Attempts to determine override ordering using the mod load order.
        [Switch]$UseLoadOrder
    )

    begin {
        $modSearcher = 'Get-RWMod'
        if ($UseLoadOrder) {
            $modSearcher = 'Get-RWModConfig'
        }

        if ($SubjectModName) {
            $null = $psboundparameters.Remove('SubjectModName')
            & $modSearcher -Name $SubjectModName | Compare-RWModDef @psboundparameters
        }
    }

    process {
        if ($SubjectModInformation) {
            $subjectModDefs = @{}
            $SubjectModInformation | Get-RWModDef | ForEach-Object {
                if ($subjectModDefs.Contains($_.ID)) {
                    Write-Warning -Message ('Duplicate Def found. {0} in {1} and {2}' -f
                        $_.DefName,
                        $_.Path,
                        $subjectModDefs[$_.ID].Path
                    )
                } else {
                    $subjectModDefs.Add($_.ID, $_)
                }
            }

            & $modSearcher -Name $ObjectModName |
                Where-Object {
                    $loadOrder = $_.LoadOrder

                    $_.Name -ne $SubjectModInformation.Name -and
                    ($_.Name -ne 'Core' -or ($IncludeCore -and $_.Name -eq 'Core'))
                } |
                Get-RWModDef |
                Where-Object { $subjectModDefs.Contains($_.ID) } |
                ForEach-Object {
                    $defConflict = [PSCustomObject]@{
                        ID             = $_.ID
                        DefName        = $_.DefName
                        SubjectMod     = $subjectModDefs[$_.ID].ModName
                        SubjectDefType = $subjectModDefs[$_.ID].DefType
                        SubjectFile    = $subjectModDefs[$_.ID].Path
                        ObjectMod      = $_.ModName
                        ObjectType     = $_.DefType
                        ObjectFile     = $_.Path
                    } | Add-Member -TypeName 'Indented.RimWorld.DefConflict' -PassThru

                    if ($UseLoadOrder) {
                        $defConflict | Add-Member State ''
                        if ($subjectModDefs[$_.ID].LoadOrder -lt $loadOrder) {
                            $defConflict.State = '{0}: {1} overrides {2}' -f
                                $_.ID,
                                $_.ModName,
                                $SubjectModInformation.Name
                        } else {
                            $defConflict.State = '{0}: {1} is used' -f 
                                $_.ID,
                                $SubjectModInformation.Name
                        }
                    }

                    $defConflict
                }
        }
    }
}