---
external help file: Indented.RimWorld-help.xml
online version: 
schema: 2.0.0
---

# Get-RWModDef

## SYNOPSIS
Get Defs from the mod.

## SYNTAX

### ByModName (Default)
```
Get-RWModDef [-ModName] <String> [-DefName <String>] [-DefType <String>] [-WarningsOnly]
```

### FromModInformation
```
Get-RWModDef [-DefName <String>] [-DefType <String>] -ModInformation <Object> [-WarningsOnly]
```

## DESCRIPTION
Get the Defs from the mod.

This function attempts to convert first-level elements from the Def XML to an object.
As properties in objects must be unique this function will also flag duplicates.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
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

### -DefType
The type of definition to search for.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: *Defs*
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

## INPUTS

### Indented.RimWorld.ModInformation
System.String

## OUTPUTS

### Indented.RimWorld.DefInformation (System.Management.Automation.PSObject)

## NOTES
Author: Chris Dent

Change log:
  15/06/2014 - Created

## RELATED LINKS

