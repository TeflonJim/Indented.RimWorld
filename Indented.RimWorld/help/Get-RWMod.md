---
external help file: Indented.RimWorld-help.xml
Module Name: Indented.RimWorld
online version:
schema: 2.0.0
---

# Get-RWMod

## SYNOPSIS
Get the mods available to RimWorld.

## SYNTAX

### ByID (Default)
```
Get-RWMod [-ID <String>] [<CommonParameters>]
```

### ByName
```
Get-RWMod [[-Name] <String>] [<CommonParameters>]
```

## DESCRIPTION
Get-RWMod searches the games mod path and the workshop mod path for mods.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -ID
The ID of a mod.
The ID is the folder name which may match the name of the mod as seen in RimWorld.

```yaml
Type: String
Parameter Sets: ByID
Aliases:

Required: False
Position: Named
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

Required: False
Position: 2
Default value: *
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### Indented.RimWorld.ModInformation
## NOTES
Change log:
    11/10/2016 - Chris Dent - Created.

## RELATED LINKS
