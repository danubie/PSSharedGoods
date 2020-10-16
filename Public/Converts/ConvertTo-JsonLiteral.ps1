﻿function ConvertTo-JsonLiteral {
    <#
    .SYNOPSIS
    Converts an object to a JSON-formatted string.

    .DESCRIPTION
    The ConvertTo-Json cmdlet converts any object to a string in JavaScript Object Notation (JSON) format. The properties are converted to field names, the field values are converted to property values, and the methods are removed.

    .PARAMETER Object
    Specifies the objects to convert to JSON format. Enter a variable that contains the objects, or type a command or expression that gets the objects. You can also pipe an object to ConvertTo-JsonLiteral

    .PARAMETER Depth
    Specifies how many levels of contained objects are included in the JSON representation. The default value is 0.

    .PARAMETER AsArray
    Outputs the object in array brackets, even if the input is a single object.

    .PARAMETER DateTimeFormat
    Changes DateTime string format. Default "yyyy-MM-dd HH:mm:ss"

    .PARAMETER NumberAsString
    Provides an alternative serialization option that converts all numbers to their string representation.

    .PARAMETER BoolAsString
    Provides an alternative serialization option that converts all bool to their string representation.

    .EXAMPLE
    Get-Process | Select-Object -First 2 | ConvertTo-JsonLiteral

    .NOTES
    General notes
    #>
    [cmdletBinding()]
    param(
        [alias('InputObject')][Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0, Mandatory)][Array] $Object,
        [int] $Depth,
        #[switch] $HashTableAsIs,
        [switch] $AsArray,
        [string] $DateTimeFormat = "yyyy-MM-dd HH:mm:ss",
        [switch] $NumberAsString,
        [switch] $BoolAsString,
        [System.Collections.IDictionary] $NewLineFormat = @{
            NewLineCarriage = '\r\n'
            NewLine         = "\n"
            Carriage        = "\r"
        }
    )
    Begin {
        $TextBuilder = [System.Text.StringBuilder]::new()
        $CountObjects = 0
        filter IsNumeric() {
            return $_ -is [byte] -or $_ -is [int16] -or $_ -is [int32] -or $_ -is [int64]  `
                -or $_ -is [sbyte] -or $_ -is [uint16] -or $_ -is [uint32] -or $_ -is [uint64] `
                -or $_ -is [float] -or $_ -is [double] -or $_ -is [decimal]
        }
        filter IsOfType() {
            return $_ -is [bool] -or $_ -is [char] -or $_ -is [datetime] -or $_ -is [string] `
                -or $_ -is [timespan] -or $_ -is [URI] `
                -or $_ -is [byte] -or $_ -is [int16] -or $_ -is [int32] -or $_ -is [int64] `
                -or $_ -is [sbyte] -or $_ -is [uint16] -or $_ -is [uint32] -or $_ -is [uint64] `
                -or $_ -is [float] -or $_ -is [double] -or $_ -is [decimal]
        }
        [int] $MaxDepth = $Depth
        [int] $InitialDepth = 0
    }
    Process {
        for ($a = 0; $a -lt $Object.Count; $a++) {
            $CountObjects++
            if ($CountObjects -gt 1) {
                $null = $TextBuilder.Append(',')
            }
            if ($Object[$a] -is [System.Collections.IDictionary]) {
                #if (-not $HashTableAsIs) {
                # Push to TEXT the same as [PSCustomObject]
                $null = $TextBuilder.AppendLine("{")
                for ($i = 0; $i -lt ($Object[$a].Keys).Count; $i++) {
                    $Property = ([string[]]$Object[$a].Keys)[$i].Replace('\', "\\").Replace('"', '\"')
                    $null = $TextBuilder.Append("`"$Property`":")
                    $Value = ConvertTo-StringByType -Value $Object[$a][$Property] -DateTimeFormat $DateTimeFormat -NumberAsString:$NumberAsString -BoolAsString:$BoolAsString -Depth $InitialDepth -MaxDepth $MaxDepth -TextBuilder $TextBuilder -NewLineFormat $NewLineFormat
                    $null = $TextBuilder.Append("$Value")
                    if ($i -ne ($Object[$a].Keys).Count - 1) {
                        $null = $TextBuilder.AppendLine(',')
                    }
                }
                $null = $TextBuilder.Append("}")
                <#
                } else {
                    # Push to TEXT as real [ordered]
                    $null = $TextBuilder.AppendLine('[')
                    for ($i = 0; $i -lt ($Object[$a].Keys).Count; $i++) {
                        $null = $TextBuilder.AppendLine("{")
                        $Property = ([string[]]$Object[$a].Keys)[$i]

                        $null = $TextBuilder.Append("`"$Property`":")
                        $Value = ConvertTo-StringByType -Value $Object[$a][$i] -DateTimeFormat $DateTimeFormat -NumberAsString:$NumberAsString -BoolAsString:$BoolAsString -Depth $InitialDepth -MaxDepth $MaxDepth -TextBuilder $TextBuilder
                        $null = $TextBuilder.Append("$Value")
                        $null = $TextBuilder.Append("}")
                        if ($i -ne ($Object[$a].Keys).Count - 1) {
                            $null = $TextBuilder.AppendLine(',')
                        }
                    }
                    $null = $TextBuilder.AppendLine(']')
                }
                #>
                #} elseif ($Object[$a].GetType().Name -match 'bool|byte|char|datetime|decimal|double|ExcelHyperLink|float|int|long|sbyte|short|string|timespan|uint|ulong|URI|ushort') {
            } elseif ($Object[$a] | IsOfType) {
                $Value = ConvertTo-StringByType -Value $Object[$a] -DateTimeFormat $DateTimeFormat -NumberAsString:$NumberAsString -BoolAsString:$BoolAsString -Depth $InitialDepth -MaxDepth $MaxDepth -TextBuilder $TextBuilder -NewLineFormat $NewLineFormat
                #$null = $TextBuilder.Append("`"$($Object[$a].ToString())`"")
                $null = $TextBuilder.Append($Value)
            } else {
                $null = $TextBuilder.AppendLine("{")
                for ($i = 0; $i -lt ($Object[$a].PSObject.Properties.Name).Count; $i++) {
                    $Property = ([string[]] $($Object[$a].PSObject.Properties.Name))[$i]
                    $TranslatedProperty = $Property.Replace('\', "\\").Replace('"', '\"')
                    $null = $TextBuilder.Append("`"$TranslatedProperty`":")
                    $Value = ConvertTo-StringByType -Value $Object[$a].$Property -DateTimeFormat $DateTimeFormat -NumberAsString:$NumberAsString -BoolAsString:$BoolAsString -Depth $InitialDepth -MaxDepth $MaxDepth -TextBuilder $TextBuilder -NewLineFormat $NewLineFormat
                    # Push to Text
                    $null = $TextBuilder.Append("$Value")
                    if ($i -ne ($Object[$a].PSObject.Properties.Name).Count - 1) {
                        $null = $TextBuilder.AppendLine(',')
                    }
                }
                $null = $TextBuilder.Append("}")
            }
            $InitialDepth = 0
        }
    }
    End {
        if ($CountObjects -gt 1 -or $AsArray) {
            "[$($TextBuilder.ToString())]"
        } else {
            $TextBuilder.ToString()
        }
    }
}