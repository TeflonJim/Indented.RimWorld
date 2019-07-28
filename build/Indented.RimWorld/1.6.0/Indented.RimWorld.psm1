function ConvertFromXElement {
    <#
    .SYNOPSIS
        Offload conversion of an XElement to a PSObject.
    .DESCRIPTION
        Offload conversion of an XElement to a PSObject.
    .INPUTS
        System.Xml.Linq.XElement
    .NOTES
        Change log:
            11/10/2016 - Chris Dent - Created.
    #>

    param (
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

function Clear-RWModConfig {
    <#
    .SYNOPSIS
        Clears the mod load list.
    .DESCRIPTION
        Clears all mods except Core from the ActiveMods list in ModsConfig.xml.
    .NOTES
        Change log:
            11/10/2016 - Chris Dent - Created.
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')] # Disable-RWMod supports this.
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([System.Void])]
    param ( )

    Get-RWModConfig | Where-Object { $_.Name -ne 'Core' } | Disable-RWMod
}

function Compare-RWModDef {
    <#
    .SYNOPSIS
        Compares Defs across mods.
    .DESCRIPTION
        Compare-RWModDef shows conflicting defNames across RimWorld mods.
    .INPUTS
        Indented.RimWorld.ModInformation
    .EXAMPLE
        Compare-RWModDef SomeMod

        Compare the Defs from SomeMod with all mods in the Mods directory.
    .EXAMPLE
        Compare-RWModDef SomeMod -ObjectModName OtherMod

        Compare the Defs from SomeMod with the Defs from OtherMod
    .EXAMPLE
        Compare-RWModDef SomeMod -ObjectModName Core -IncludeCore

        Show the Defs from SomeMod which override the Defs in Core.
    .NOTES
        Change log:
            15/06/2014 - Chris Dent - Created
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [CmdletBinding(DefaultParameterSetName = 'ByModName')]
    [OutputType('Indented.RimWorld.DefConflict')]
    param (
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
            $SubjectModInformation | Get-RWModDef | Where-Object IsAbstract -eq $false | ForEach-Object {
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
                Where-Object { $_.IsAbstract -eq $false -and $subjectModDefs.Contains($_.ID) } |
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
                        PSTypeName     = 'Indented.RimWorld.DefConflict'
                    }

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

function Compare-RWModProfile {
    <#
    .SYNOPSIS
        Shows an overview of the mods across each profile.
    .DESCRIPTION
        Gets the list of all available mods then shows if a mod is used by a mod profile.
    .NOTES
        Change log:
            04/12/2016 - Chris Dent - Created.
    #>

    [OutputType('Indented.RimWorld.ModProfileEntry')]
    param ( )

    if (Test-Path $Script:ModProfilePath\*) {
        $mods = New-Object System.Collections.Generic.Dictionary'[String,PSObject]'
        Get-RWMod | Sort-Object Name | ForEach-Object {
            $mods.Add(
                $_.RawName,
                ([PSCustomObject]@{ Name = $_.RawName } | Add-Member -TypeName 'Indented.RimWorld.ModProfileEntry' -PassThru)
            )
        }

        $allProfileNames = New-Object System.Collections.Generic.List[String]
        Get-RWModProfile | ForEach-Object {
            $allProfileNames.Add($_.ProfileName)
            $i = 0
            foreach ($mod in $_.ModList) {
                Add-Member $_.ProfileName $i -InputObject $mods.($mod.RawName)
                $i++
            }
        }

        # Normalise
        foreach ($value in $mods.Values) {
            foreach ($profileName in $allProfileNames) {
                if ($null -eq ($value.PSObject.Properties.Item($profileName))) {
                    Add-Member $profileName $null -InputObject $value
                }
            }
        }

        $mods.Values
    } else {
        Write-Warning 'No mod profiles have been configured.'
    }
}

function Copy-RWModDef {
    <#
    .SYNOPSIS
        Copies a definition from a mod.
    .DESCRIPTION
        Copies a definition from a mod.
    #>

    [CmdletBinding()]
    [OutputType([System.Xml.Linq.XDocument])]
    param (
        [Parameter(Mandatory = $true)]
        [String]$Name,

        [String]$DefType,

        [String]$NewName,

        [String[]]$Remove,

        [Hashtable]$Update,

        [ValidateScript( { Test-Path $_ -PathType Leaf } )]
        [String]$SaveAs
    )

    $id = $Name
    if ($DefType) {
        $id = '{0}\{1}' -f $Name, $DefType
    }

    $modName, $defName = $Name -split '[\\/]'
    if ($null -eq $modName) {
        $modName = 'Core'
    }

    if ($null -eq $Script:defCopyCache) {
        $Script:defCopyCache = @{}
    }
    if ($Script:defCopyCache.Contains($id)) {
        $def = $Script:defCopyCache[$id]
    } else {
        $params = @{
            ModName = $modName
            DefName = $defName
        }
        if ($DefType) {
            $params.DefType = $DefType
        }
        $def = Get-RWModDef @params | ForEach-Object { $_.XElement.ToString() }
        $Script:defCopyCache.Add($id, $def)
    }

    if ($null -eq $def) {
        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
            [ArgumentException]::new('Cannot locate source def'),
            'UnknownDef',
            [System.Management.Automation.ErrorCategory]::InvalidArgument,
            $id
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
                            [System.Xml.Linq.XElement]::new(
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
                            [System.Xml.Linq.XElement]::new(
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

function Disable-RWMod {
    <#
    .SYNOPSIS
        Disable a mod in the list of active mods.
    .DESCRIPTION
        Removes a single mod from the list of active mods.
    .INPUTS
        System.String
    .NOTES
        Change log:
            11/10/2016 - Chris Dent - Created.
    #>

    [CmdletBinding(DefaultParameterSetName = 'ByID', SupportsShouldProcess = $true)]
    [OutputType([System.Void])]
    param (
        # The ID of a mod to disable. The ID is the folder name which may match the name of the mod as seen in RimWorld.
        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByID')]
        [String]$ID,

        # The name of the mod as seen in RimWorld.
        [Parameter(Mandatory = $true, ParameterSetName = 'ByName')]
        [String]$Name
    )

    begin {
        if ($pscmdlet.ParameterSetName -eq 'ByName') {
            Get-RWMod -Name $Name | Disable-RWMod
        }
        if ($pscmdlet.ParameterSetName -eq 'ByID') {
            $content = [XML](Get-Content $Script:ModConfigPath -Raw)
        }
    }

    process {
        if ($pscmdlet.ParameterSetName -eq 'ByID') {
            if ($pscmdlet.ShouldProcess(('Removing {0} from the active mods list' -f $ID))) {
                $content.ModsConfigData.activeMods.SelectSingleNode(('./li[.="{0}"]' -f $ID)).
                                                   CreateNavigator().
                                                   DeleteSelf()
            }
        }
    }

    end {
        if ($pscmdlet.ParameterSetName -eq 'ByID') {
            $content.Save($Script:ModConfigPath)
        }
    }
}

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

function Enable-RWMod {
    <#
    .SYNOPSIS
        Enable a mod in the list of active mods.
    .DESCRIPTION
        Adds a single mod to the list of active mods.
    .INPUTS
        System.String
    .NOTES
        Change log:
            11/10/2016 - Chris Dent - Created.
    #>

    [CmdletBinding(DefaultParameterSetName = 'ByID', SupportsShouldProcess = $true)]
    [OutputType([System.Void])]
    param (
        # The ID of a mod to disable. The ID is the folder name which may match the name of the mod as seen in RimWorld.
        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByID')]
        [String]$ID,

        # The name of the mod as seen in RimWorld.
        [Parameter(Mandatory = $true, ParameterSetName = 'ByName')]
        [String]$Name,

        # The position the mod should be loaded in. By default mods are added to the end of the list of active mods.
        [ValidateRange(2, 1024)]
        [Int32]$LoadOrder = 1024
    )

    begin {
        if ($pscmdlet.ParameterSetName -eq 'ByName') {
            Get-RWMod -Name $Name | Disable-RWMod
        }
        if ($pscmdlet.ParameterSetName -eq 'ByID') {
            $content = [XML](Get-Content $Script:ModConfigPath -Raw)
        }
    }

    process {
        if ($pscmdlet.ParameterSetName -eq 'ByID') {
            $rwMod = Get-RWMod -ID $ID

            $supported = $false
            foreach ($version in $rwMod.SupportedVersions) {
                $version = [Version]$version
                if ($version.Major -eq $Script:GameVersion.Major -and $version.Minor -eq $Script:GameVersion.Minor) {
                    $supported = $true

                    Write-Verbose ('Enabling mod {0}' -f $mod)

                    if ($LoadOrder -gt @($content.ModsConfigData.activeMods).Count) {
                        $predecessorID = @($content.ModsConfigData.activeMods.li)[-1]
                    } else {
                        $predecessorID = @($content.ModsConfigData.activeMods.li)[($LoadOrder - 1)]
                    }
                    if ($pscmdlet.ShouldProcess(('Adding {0} to the active mods list' -f $ID))) {
                        $content.ModsConfigData.activeMods.SelectSingleNode(('./li[.="{0}"]' -f $predecessorID)).
                                                           CreateNavigator().
                                                           InsertAfter(('<li>{0}</li>' -f [System.Web.HttpUtility]::HtmlAttributeEncode($ID)))
                    }
                }
            }
            if (-not $supported) {
                Write-Warning ('Unable to enable mod {0}. Not compatible with RimWorld version {1}.' -f $rwMod.Name, $Script:GameVersion)
            }
        }
    }

    end {
        if ($pscmdlet.ParameterSetName -eq 'ByID') {
            $content.Save($Script:ModConfigPath)
        }
    }
}

function Get-RWMod {
    <#
    .SYNOPSIS
        Get the mods available to RimWorld.
    .DESCRIPTION
        Get-RWMod searches the games mod path and the workshop mod path for mods.
    .INPUTS
        System.String
    .NOTES
        Change log:
            11/10/2016 - Chris Dent - Created.
    #>

    [CmdletBinding(DefaultParameterSetName = 'ByID')]
    [OutputType('Indented.RimWorld.ModInformation')]
    param (
        # The ID of a mod. The ID is the folder name which may match the name of the mod as seen in RimWorld.
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByID')]
        [String]$ID,

        # The name of the mod as seen in RimWorld.
        [Parameter(Position = 1, ParameterSetName = 'ByName')]
        [String]$Name = '*'
    )

    begin {
        if ($pscmdlet.ParameterSetName -eq 'ByName') {
            if ($Script:ModSearchCache.Contains($Name)) {
                $rwMod = Get-RWMod -ID $Script:ModSearchCache[$Name]
                if ($rwMod) {
                    $rwMod
                } else {
                    # Try and search again if the cache item appears to have become invalid.
                    $Script:ModSearchCache.Remove($Name)
                    Get-RWMod -Name $Name
                }
            } else {
                Get-RWMod | Where-Object { $_.Name -like $Name -or $_.Name -eq $Name }
            }
        }
    }

    process {
        if ($pscmdlet.ParameterSetName -eq 'ByID') {
            if ($psboundparameters.ContainsKey('ID')) {
                if ([Int32]::TryParse($ID, [Ref]$null)) {
                    $modPath = Join-Path $Script:WorkshopModPath $ID
                } else {
                    $modPath = Join-Path $Script:GameModPath $ID
                }
                $aboutPath = Join-Path $modPath 'About\about.xml'
                # Test-Path doesn't get on well with some special characters and has no literal path parameter.
                if ([System.IO.File]::Exists($aboutPath)) {
                    try {
                        $xmlDocument = [Xml](Get-Content $aboutPath -Raw)
                        $xmlNode = $xmlDocument.ModMetaData
                        $modMetaData = [PSCustomObject]@{
                            Name              = ($xmlNode.name -replace ' *\(?(\[?[ABv]?\d+(\.\d+)*\]?[a-z]*\,?)+\)?').Trim(' _-')
                            RawName           = $xmlNode.name
                            ID                = $ID
                            Version           = $xmlNode.version
                            Author            = $xmlNode.author
                            Description       = $xmlNode.description
                            URL               = $xmlNode.url
                            SupportedVersions = $xmlNode.targetVersion
                            Path              = $modPath
                            PSTypeName        = 'Indented.RimWorld.ModInformation'
                        }
                        if ($xmlNode.SupportedVersions) {
                            $modMetaData.SupportedVersions = $xmlNode.SupportedVersions.li
                        }

                        # Best effort version parser
                        $regex = '(?:v(?:ersion:?)? *)?((?:\d+\.){1,}\d+)'
                        if ($modMetaData.Name -match $regex -or $modMetaData.Description -match $regex) {
                            $modMetaData.Version = $matches[1]
                        }
                        if (-not $Script:ModSearchCache.Contains($modMetaData.Name)) {
                            $Script:ModSearchCache.Add($modMetaData.Name, $ID)
                        }

                        $modMetaData
                    } catch {
                        Write-Error ('Error reading {0}: {1}' -f $aboutPath, $_.Exception.Message.Trim())
                    }
                }
            } else {
                foreach ($path in ($Script:GameModPath, $Script:WorkshopModPath)) {
                    Get-ChildItem $path -Directory | Get-RWMod -ID { $_.Name }
                }
            }
        }
    }
}

function Get-RWModConfig {
    <#
    .SYNOPSIS
        Get the list of active mods.
    .DESCRIPTION
        Get-RWModConfig reads the activeMods list from ModsConfig.xml.
    .NOTES
        Change log:
            11/10/2016 - Chris Dent - Created.
    #>

    [CmdletBinding()]
    [OutputType('Indented.RimWorld.ModInformation')]
    param (
        # The name of the mod as seen in RimWorld.
        [String]$Name
    )

    if (Test-Path $Script:ModConfigPath) {
        $i = 1
        foreach ($mod in [System.Xml.Linq.XDocument]::Load($Script:ModConfigPath).Element('ModsConfigData').Element('activeMods').Elements('li').Value) {
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

function Get-RWModDef {
    <#
    .SYNOPSIS
        Get Defs from the mod.
    .DESCRIPTION
        Get the Defs from the mod.

        This function attempts to convert first-level elements from the Def XML to an object. As properties in objects must be unique this function will also flag duplicates.
    .INPUTS
        Indented.RimWorld.ModInformation
    .EXAMPLE
        Get-RWMod SomeMod | Get-RWModDef
    #>

    [CmdletBinding(DefaultParameterSetName = 'ByModName')]
    [OutputType('Indented.RimWorld.DefInformation')]
    param (
        # Get Defs from the specified mod name.
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'ByModName')]
        [String]$ModName,

        # The name of a Def to retrieve.
        [String]$DefName,

        # The def type to find.
        [String]$DefType,

        # Accepts an output pipeline from Get-RWMod.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'FromModInformation')]
        [PSTypeName('Indented.RimWorld.ModInformation')]
        $ModInformation,

        # Only show warnings
        [Switch]$WarningsOnly
    )

    begin {
        if ($pscmdlet.ParameterSetName -eq 'ByModName') {
            $null = $psboundparameters.Remove('ModName')
            Get-RWMod -Name $ModName | Get-RWModDef @psboundparameters
        }
    }

    process {
        if ($pscmdlet.ParameterSetName -eq 'FromModInformation') {
            $defsPath = Join-Path $ModInformation.Path 'Defs'
            if ([System.IO.Directory]::Exists($defsPath)) {
                Get-ChildItem -LiteralPath $defsPath -File -Filter *.xml -Recurse | ForEach-Object {
                    $path = $_.FullName
                    $name = $_.Name

                    Write-Verbose -Message ('Reading {0}' -f $path)

                    try {
                        $xDocument = [System.Xml.Linq.XDocument]::Load($path)
                        if ($DefType) {
                            $xpathQuery = '/Defs/{0}' -f $DefType
                        } else {
                            $xpathQuery = '/Defs/*'
                        }
                        if ($DefName) {
                            $xpathQuery = (@(
                                '({0}[contains(translate(defName, "ABCDEFGHIJKLMNOPQRSTUVWXYZ", "abcdefghijklmnopqrstuvwxyz"), "{1}") or'
                                'contains(translate(@Name, "ABCDEFGHIJKLMNOPQRSTUVWXYZ", "abcdefghijklmnopqrstuvwxyz"), "{1}")])'
                            ) -join ' ') -f @(
                                $xPathQuery
                                $DefName.ToLower()
                            )
                        }
                        [System.Xml.XPath.Extensions]::XPathSelectElements(
                            $xDocument,
                            $xpathQuery
                        ) | ForEach-Object {
                            if (-not $WarningsOnly) {
                                $def = [PSCustomObject]@{
                                    DefName    = $_.Elements().Where( { $_.Name.ToString() -eq 'defName' } ).Value
                                    DefType    = $_.Name
                                    ID         = ''
                                    ModName    = $ModInformation.Name
                                    Def        = $_ | ConvertFromXElement
                                    Path       = $path
                                    XElement   = $_
                                    IsAbstract = $false
                                    PSTypeName = 'Indented.RimWorld.DefInformation'
                                }
                                if ($abstract = $_.Attributes().Where( { $_.Name.LocalName -eq 'Abstract' } )) {
                                    $def.IsAbstract = (Get-Variable $abstract.Value).Value
                                    $def.DefName = $_.Attributes().Where( { $_.Name.LocalName -eq 'Name' }).Value
                                }
                                $def.ID = '{0}\{1}' -f $def.DefType, $def.DefName

                                $def
                            }
                        }
                    } catch {
                        Write-Warning -Message ('Error loading XML file from {0}\{1} ({2})' -f $ModInformation.Name, $name, $_.Exception.Message)
                    }
                } | Where-Object { $DefName -eq '' -or $_.DefName -like $DefName }
            }
        }
    }
}

function Get-RWModProfile {
    <#
    .SYNOPSIS
        Get configured mod profiles.
    .DESCRIPTION
        Gets each mod profile and the list of mods it contains.
    .INPUTS
        System.String
    .NOTES
        Change log:
            04/12/2016 - Chris Dent - Created.
    #>

    [CmdletBinding()]
    [OutputType('Indented.RimWorld.ModProfileInformation')]
    param (
        # The profile name to get. By default the command returns information about all profiles.
        [Parameter(Position = 1, ParameterSetName = 'ByProfileName')]
        [String]$ProfileName = '*'
    )

    Get-ChildItem $Script:ModProfilePath -Filter ('{0}.txt' -f $ProfileName) | ForEach-Object {
        $modProfile = Get-Content $_.FullName -Raw
        $modList = foreach ($mod in $modProfile.Split("`r`n", [System.StringSplitOptions]::RemoveEmptyEntries)) {
            $mod = $mod.Trim()
            if ($mod -and -not $mod.StartsWith('#')) {
                $rwMod = Get-RWMod -Name $mod
                if ($rwMod) {
                    $rwMod
                }
            }
        }
        [PSCustomObject]@{
            ProfileName = $_.BaseName
            ModList     = $modList
        }
    }
}

function Import-RWModProfile {
    <#
    .SYNOPSIS
        Import a mod profile.
    .DESCRIPTION
        Imports a list of mods into the active mods list. This overwrites any existing mods.
    .NOTES
        Change log:
            11/10/2016 - Chris Dent - Created.
    #>

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')] # All commands used by this support ShouldProcess.
    [CmdletBinding(DefaultParameterSetName = 'ByProfileName', SupportsShouldProcess = $true)]
    [OutputType([System.Void])]
    param (
        # The name of a profile to import.
        [Parameter(Position = 1, ParameterSetName = 'ByProfileName')]
        [String]$ProfileName = 'Default',

        # The path to a file containing a profile description.
        [Parameter(ParameterSetName = 'FromPath')]
        [ValidateScript( { Test-Path $_ } )]
        [String]$Path,

        # A list of mods to activate.
        [Parameter(ParameterSetName = 'FromString')]
        [String]$ModProfile
    )

    if ($pscmdlet.ParameterSetName -eq 'ByProfileName') {
        $Path = Join-Path $Script:ModProfilePath ('{0}.txt' -f $ProfileName)
    }

    if (-not [String]::IsNullOrEmpty($Path) -and (Test-Path $Path -PathType Leaf)) {
        $ModProfile = Get-Content $Path -Raw
    }

    if (-not [String]::IsNullOrEmpty($ModProfile)) {
        Clear-RWModConfig
        foreach ($mod in $ModProfile.Split("`r`n", [System.StringSplitOptions]::RemoveEmptyEntries)) {
            $mod = $mod.Trim()
            if ($mod -and -not $mod.StartsWith('#')) {
                $rwMod = Get-RWMod -Name $mod
                if ($rwMod) {
                    $rwMod | Enable-RWMod
                } else {
                    Write-Warning ('Unable to find mod {0}' -f $mod)
                }
            }
        }
    }
}

function Open-RWDirectory {
    <#
    .SYNOPSIS
        Opens a folder using a tag.
    .DESCRIPTION
        A simple way to open any of the folders used by RimWorld or this module.
    .INPUTS
        System.String
    .NOTES
        Change log:
            11/10/2016 - Chris Dent - Created.
    #>

    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    [OutputType([System.Void])]
    param (
        # The name, or tag, of the directory to open.
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'ByName')]
        [ValidateSet('Game', 'GameMods', 'WorkshopMods', 'UserSettings', 'ModProfiles')]
        [String]$Name,

        # Open a directory for an existing mod.
        [Parameter(ValueFromPipeline = $true, ParameterSetName = 'FromModInformation')]
        [PSTypeName('Indented.RimWorld.ModInformation')]
        [PSObject]$ModInformation
    )

    begin {
        if ($pscmdlet.ParameterSetName -eq 'ByName') {
            switch ($Name) {
                'Game'         { Invoke-Item $Script:GamePath; break }
                'GameMods'     { Invoke-Item $Script:GameModPath; break }
                'WorkshopMods' { Invoke-Item $Script:WorkshopModPath; break }
                'UserSettings' { Invoke-Item $Script:UserSettings; break }
                'ModProfiles'  { Invoke-Item $Script:ModProfilePath; break }
            }
        }
    }

    process {
        if ($pscmdlet.ParameterSetName -eq 'FromModInformation') {
            Invoke-Item $ModInformation.Path
        }
    }
}

function Set-RWGamePath {
    <#
    .SYNOPSIS
        Set the path to RimWorld if it cannot be discovered.
    .DESCRIPTION
        The path to the RimWorld game is used to discover the mods installed into the games directory.
    .NOTES
        Change log:
            21/12/2016 - Chris Dent - Created.
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')] # All commands used by this support ShouldProcess.
    [CmdletBinding()]
    param (
        # The path to the game.
        [ValidateScript( { Test-Path $_ -PathType Container } )]
        [String]$Path
    )

    if (-not (Test-Path (Split-Path $Script:ModuleConfigPath -Parent))) {
        $null = New-Item (Split-Path $Script:ModuleConfigPath -Parent) -ItemType Directory
    }
    [PSCustomObject]@{
        GamePath = $Path
    } | ConvertTo-Json | Out-File $Script:ModuleConfigPath -Encoding utf8
}

function InitializeModule {
    # Paths

    $Script:ModuleConfigPath = [System.IO.Path]::Combine(
        $home,
        'Documents',
        'WindowsPowerShell',
        'Config',
        'Indented.Rimworld.config'
    )

    if (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 294100') {
        $Script:GamePath = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 294100' -Name 'InstallLocation').InstallLocation
    } elseif (Test-Path $configPath) {
        $Script:GamePath = (ConvertFrom-Json (Get-Content $configPath -Raw)).GamePath
    } else {
        throw 'GamePath is not discoverable and not set. Please set a game path with Set-RWGamePath'
    }

    $Script:GameVersion = [Version]((Get-Content (Join-Path $Script:GamePath 'Version.txt') -Raw) -replace ' .+$')
    $Script:GameModPath = Join-Path $Script:GamePath 'Mods'

    $Script:WorkshopModPath = [System.IO.Path]::Combine(
        ([System.IO.DirectoryInfo]$Script:GamePath).Parent.Parent.FullName,
        'workshop',
        'content',
        '294100'
    )

    $Script:UserSettings = [System.IO.Path]::Combine(
        $env:USERPROFILE,
        'AppData',
        'LocalLow',
        'Ludeon Studios',
        'RimWorld by Ludeon Studios'
    )

    $Script:ModConfigPath = [System.IO.Path]::Combine(
        $Script:UserSettings,
        'Config',
        'ModsConfig.xml'
    )

    $Script:ModProfilePath = Join-Path $Script:UserSettings 'ModProfiles'

    # Cache

    $Script:ModSearchCache = @{}

    # Set-up

    if ((Test-Path $Script:UserSettings) -and -not (Test-Path $Script:ModProfilePath)) {
        $null = New-Item $Script:ModProfilePath -ItemType Directory
    }
}

InitializeModule
