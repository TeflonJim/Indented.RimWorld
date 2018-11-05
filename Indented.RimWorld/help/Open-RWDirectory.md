---
external help file: Indented.RimWorld-help.xml
Module Name: Indented.RimWorld
online version:
schema: 2.0.0
---

# Open-RWDirectory

## SYNOPSIS
Opens a folder using a tag.

## SYNTAX

### ByName (Default)
```
Open-RWDirectory [-Name] <String> [<CommonParameters>]
```

### FromModInformation
```
Open-RWDirectory [-ModInformation <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
A simple way to open any of the folders used by RimWorld or this module.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Name
The name, or tag, of the directory to open.

```yaml
Type: String
Parameter Sets: ByName
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModInformation
Open a directory for an existing mod.

```yaml
Type: PSObject
Parameter Sets: FromModInformation
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
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
