---
external help file: Indented.RimWorld-help.xml
Module Name: Indented.RimWorld
online version:
schema: 2.0.0
---

# Enable-RWMod

## SYNOPSIS
Enable a mod in the list of active mods.

## SYNTAX

### ByPackageID (Default)
```
Enable-RWMod [-PackageID] <String> [-LoadOrder <Int32>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ByName
```
Enable-RWMod -Name <String> [-LoadOrder <Int32>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Adds a single mod to the list of active mods.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -PackageID
The ID of a mod to enable.
The ID is the folder name which may match the name of the mod as seen in RimWorld.

```yaml
Type: String
Parameter Sets: ByPackageID
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
The name of the mod as seen in RimWorld.

```yaml
Type: String
Parameter Sets: ByName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -LoadOrder
The position the mod should be loaded in.
By default mods are added to the end of the list of active mods.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 1024
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### System.Void
## NOTES
Change log:
    11/10/2016 - Chris Dent - Created.

## RELATED LINKS
