---
external help file: Indented.RimWorld-help.xml
Module Name: Indented.RimWorld
online version:
schema: 2.0.0
---

# Copy-RWModDef

## SYNOPSIS
Copies a definition from a mod.

## SYNTAX

### CopyFromMod (Default)
```
Copy-RWModDef -Name <String> [-DefType <String>] [-NewName <String>] [-Remove <String[]>] [-Update <Hashtable>]
 [-SaveAs <String>] [<CommonParameters>]
```

### CreateFromDef
```
Copy-RWModDef -Def <String> [-NewName <String>] [-Remove <String[]>] [-Update <Hashtable>] [-SaveAs <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Copies a definition from a mod.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Name
{{ Fill Name Description }}

```yaml
Type: String
Parameter Sets: CopyFromMod
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DefType
{{ Fill DefType Description }}

```yaml
Type: String
Parameter Sets: CopyFromMod
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Def
{{ Fill Def Description }}

```yaml
Type: String
Parameter Sets: CreateFromDef
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NewName
{{ Fill NewName Description }}

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

### -Remove
{{ Fill Remove Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Update
{{ Fill Update Description }}

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SaveAs
{{ Fill SaveAs Description }}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Xml.Linq.XDocument
## NOTES

## RELATED LINKS
