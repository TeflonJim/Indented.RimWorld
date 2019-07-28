---
external help file: Indented.RimWorld-help.xml
Module Name: Indented.RimWorld
online version:
schema: 2.0.0
---

# Import-RWModProfile

## SYNOPSIS
Import a mod profile.

## SYNTAX

### ByProfileName (Default)
```
Import-RWModProfile [[-ProfileName] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### FromPath
```
Import-RWModProfile [-Path <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### FromString
```
Import-RWModProfile [-ModProfile <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Imports a list of mods into the active mods list.
This overwrites any existing mods.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -ProfileName
The name of a profile to import.

```yaml
Type: String
Parameter Sets: ByProfileName
Aliases:

Required: False
Position: 2
Default value: Default
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
The path to a file containing a profile description.

```yaml
Type: String
Parameter Sets: FromPath
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModProfile
A list of mods to activate.

```yaml
Type: String
Parameter Sets: FromString
Aliases:

Required: False
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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Void
## NOTES
Change log:
    11/10/2016 - Chris Dent - Created.

## RELATED LINKS
