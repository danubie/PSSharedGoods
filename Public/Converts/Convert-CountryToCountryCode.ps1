﻿function Convert-CountryToCountryCode {
    <#
    .SYNOPSIS
    Converts a country name to a country code, or when used with a switch to full culture information

    .DESCRIPTION
    Converts a country name to a country code, or when used with a switch to full culture information

    .PARAMETER CountryName
    Country name in it's english name

    .PARAMETER All
    Provide full culture information rather than just the country code

    .EXAMPLE
    Convert-CountryToCountryCode -CountryName 'Poland'

    .EXAMPLE
    Convert-CountryToCountryCode -CountryName 'Poland' -All

    .EXAMPLE
    $Test = Convert-CountryToCountryCode
    $Test['India']['Culture']
    $Test['India']['RegionInformation']

    .EXAMPLE
    $Test = Convert-CountryToCountryCode
    $Test['Poland']['Culture']
    $Test['Poland']['RegionInformation']

    .EXAMPLE
    Convert-CountryToCountryCode -CountryName 'Polska'
    Convert-CountryToCountryCode -CountryName 'Poland'
    Convert-CountryToCountryCode -CountryName 'CZECH REPUBLIC'
    Convert-CountryToCountryCode -CountryName 'USA'

    .NOTES
    General notes
    #>
    [cmdletBinding()]
    param(
        [string] $CountryName,
        [switch] $All
    )
    if ($Script:QuickSearchCountries) {
        if ($CountryName) {
            if ($All) {
                $Script:QuickSearchCountries[$CountryName]
            } else {
                if ($Script:QuickSearchCountries[$CountryName]) {
                    $Script:QuickSearchCountries[$CountryName].RegionInformation.TwoLetterISORegionName.ToUpper()
                } else {
                    if ($PSBoundParameters.ErrorAction -eq 'Stop') {
                        throw "Country $CountryName not found"
                    } else {
                        Write-Warning -Message "Convert-CountryToCountryCode - Country $CountryName name not found"
                    }
                }
            }
        } else {
            $Script:QuickSearchCountries
        }
    } else {

        $AllCultures = [cultureinfo]::GetCultures([System.Globalization.CultureTypes]::SpecificCultures)
        $Script:QuickSearchCountries = [ordered] @{
            # This is for custom countries that are not in the list by their english name.
            # there also seems to be a difference between PS7 and PS5.1
            # Net framework vs NET Core
            'Czech Republic'  = @{
                'Culture'           = [cultureinfo] 'CZ'
                'RegionInformation' = [System.Globalization.RegionInfo] 'CZ'
            }
            'Korea, REPUBLIC OF' = @{
                'Culture'           = [cultureinfo] 'KR'
                'RegionInformation' = [System.Globalization.RegionInfo] 'KR'
            }
            'VIET NAM'        = @{
                'Culture'           = [cultureinfo] 'VN'
                'RegionInformation' = [System.Globalization.RegionInfo] 'VN'
            }
        }
        foreach ($Culture in $AllCultures) {
            $RegionInformation = [System.Globalization.RegionInfo]::new($Culture)
            $Script:QuickSearchCountries[$RegionInformation.EnglishName] = @{
                'Culture'           = $Culture
                'RegionInformation' = $RegionInformation
            }
            $Script:QuickSearchCountries[$RegionInformation.DisplayName] = @{
                'Culture'           = $Culture
                'RegionInformation' = $RegionInformation
            }
            $Script:QuickSearchCountries[$RegionInformation.NativeName] = @{
                'Culture'           = $Culture
                'RegionInformation' = $RegionInformation
            }
            $Script:QuickSearchCountries[$RegionInformation.ThreeLetterISORegionName] = @{
                'Culture'           = $Culture
                'RegionInformation' = $RegionInformation
            }
        }
        if ($CountryName) {
            if ($All) {
                $Script:QuickSearchCountries[$CountryName]
            } else {
                if ($Script:QuickSearchCountries[$CountryName]) {
                    $Script:QuickSearchCountries[$CountryName].RegionInformation.TwoLetterISORegionName.ToUpper()
                } else {
                    if ($PSBoundParameters.ErrorAction -eq 'Stop') {
                        throw "Country $CountryName not found"
                    } else {
                        Write-Warning -Message "Convert-CountryToCountryCode - Country $CountryName name not found"
                    }
                }
            }
        } else {
            $Script:QuickSearchCountries
        }
    }
}