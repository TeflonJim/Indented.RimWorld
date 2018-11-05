---
external help file: Indented.RimWorld-help.xml
Module Name: Indented.RimWorld
online version:
schema: 2.0.0
---

# Get-RWModDef

## SYNOPSIS
Get Defs from the mod.

## SYNTAX

### ByModName (Default)
```
Get-RWModDef [-ModName] <String> [-DefName <String>] [-WarningsOnly] [<CommonParameters>]
```

### FromModInformation
```
Get-RWModDef [-DefName <String>] -ModInformation <Object> [-WarningsOnly] [<CommonParameters>]
```

## DESCRIPTION
Get the Defs from the mod.

This function attempts to convert first-level elements from the Def XML to an object.
As properties in objects must be unique this function will also flag duplicates.

## EXAMPLES

### EXAMPLE 1
```
Get-RWMod SomeMod | Get-RWModDef
```

## PARAMETERS

### -ModName
Get Defs from the specified mod name.

```yaml
Type: String
Parameter Sets: ByModName
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DefName
The name of a Def to retrieve.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModInformation
Accepts an output pipeline from Get-RWMod.

```yaml
Type: Object
Parameter Sets: FromModInformation
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -WarningsOnly
Only show warnings

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Indented.RimWorld.ModInformation
## OUTPUTS

### Indented.RimWorld.DefInformation
## NOTES
Change log:
    15/06/2014 - Chris Dent - Created

## RELATED LINKS
