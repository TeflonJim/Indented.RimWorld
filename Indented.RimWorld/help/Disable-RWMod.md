---
external help file: Indented.RimWorld-help.xml
Module Name: Indented.RimWorld
online version:
schema: 2.0.0
---

# Disable-RWMod

## SYNOPSIS
Disable a mod in the list of active mods.

## SYNTAX

### ByID (Default)
```
Disable-RWMod [-ID] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ByName
```
Disable-RWMod -Name <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Removes a single mod from the list of active mods.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -ID
The ID of a mod to disable.
The ID is the folder name which may match the name of the mod as seen in RimWorld.

```yaml
Type: String
Parameter Sets: ByID
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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### System.Void
## NOTES
Change log:
    11/10/2016 - Chris Dent - Created.

## RELATED LINKS
