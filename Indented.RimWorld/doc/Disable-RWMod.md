---
external help file: Indented.RimWorld-help.xml
online version: 
schema: 2.0.0
---

# Disable-RWMod

## SYNOPSIS
Disable a mod in the list of active mods.

## SYNTAX

### ByID (Default)
```
Disable-RWMod [-ID] <String> [-WhatIf] [-Confirm]
```

### ByName
```
Disable-RWMod -Name <String> [-WhatIf] [-Confirm]
```

## DESCRIPTION
Removes a single mod from the list of active mods.

## EXAMPLES

### Example 1
```
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

## INPUTS

### System.String

## OUTPUTS

### None

## NOTES
Author: Chris Dent

Change log:
  11/10/2016 - Chris Dent - Created.

## RELATED LINKS

