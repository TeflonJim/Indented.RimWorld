---
external help file: Indented.RimWorld-help.xml
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
```

### FromModInformation
```
Compare-RWModDef [[-ObjectModName] <String>] -SubjectModInformation <Object> [-IncludeCore] [-UseLoadOrder]
```

## DESCRIPTION
Compare-RWModDef shows conflicting defNames across RimWorld mods.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Compare-RWModDef SomeMod
```

Compare the Defs from SomeMod with all mods in the Mods directory.

### -------------------------- EXAMPLE 2 --------------------------
```
Compare-RWModDef SomeMod -ObjectModName OtherMod
```

Compare the Defs from SomeMod with the Defs from OtherMod

### -------------------------- EXAMPLE 3 --------------------------
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

## INPUTS

### Indented.RimWorld.Mod
System.String

## OUTPUTS

### Indented.RimWorld.DefConflict

## NOTES
Author: Chris Dent

Change log:
  15/06/2014 - Created

## RELATED LINKS

