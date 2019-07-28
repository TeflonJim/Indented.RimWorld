---
external help file: Indented.RimWorld-help.xml
Module Name: Indented.RimWorld
online version:
schema: 2.0.0
---

# Get-RWModProfile

## SYNOPSIS
Get configured mod profiles.

## SYNTAX

```
Get-RWModProfile [[-ProfileName] <String>] [<CommonParameters>]
```

## DESCRIPTION
Gets each mod profile and the list of mods it contains.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -ProfileName
The profile name to get.
By default the command returns information about all profiles.

```yaml
Type: String
Parameter Sets: (All)
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

### Indented.RimWorld.ModProfileInformation
## NOTES
Change log:
    04/12/2016 - Chris Dent - Created.

## RELATED LINKS
