---
external help file: Indented.RimWorld-help.xml
Module Name: Indented.RimWorld
online version:
schema: 2.0.0
---

# Compare-RWModDef

## SYNOPSIS
Compares Defs across mods.

## SYNTAX

### ByModName (Default)
```
Compare-RWModDef [-SubjectModName] <String> [[-ObjectModName] <String>] [-IncludeCore] [-UseLoadOrder]
 [<CommonParameters>]
```

### FromModInformation
```
Compare-RWModDef [[-ObjectModName] <String>] -SubjectModInformation <Object> [-IncludeCore] [-UseLoadOrder]
 [<CommonParameters>]
```

## DESCRIPTION
Compare-RWModDef shows conflicting defNames across RimWorld mods.

## EXAMPLES

### EXAMPLE 1
```
Compare-RWModDef SomeMod
```

Compare the Defs from SomeMod with all mods in the Mods directory.

### EXAMPLE 2
```
Compare-RWModDef SomeMod -ObjectModName OtherMod
```

Compare the Defs from SomeMod with the Defs from OtherMod

### EXAMPLE 3
```
Compare-RWModDef SomeMod -ObjectModName Core -IncludeCore
```

Show the Defs from SomeMod which override the Defs in Core.

## PARAMETERS

### -SubjectModName
The mod to test.

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

### -ObjectModName
The mod to compare with.
If no mod name is supplied the subject is compared with all mods.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: *
Accept pipeline input: False
Accept wildcard characters: False
```

### -SubjectModInformation
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

### -IncludeCore
By default Core is excluded from the comparison; overriding core is expected behaviour.
Conflicts with Core can be displayed using this parameter.

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

### -UseLoadOrder
Attempts to determine override ordering using the mod load order.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Indented.RimWorld.ModInformation
## OUTPUTS

### Indented.RimWorld.DefConflict
## NOTES
Change log:
    15/06/2014 - Chris Dent - Created

## RELATED LINKS
