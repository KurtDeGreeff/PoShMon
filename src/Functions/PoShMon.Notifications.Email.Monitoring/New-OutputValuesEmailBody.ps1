Function New-OutputValuesEmailBody
{
    [cmdletbinding()]
    param(
        $outputHeaders,
        $outputValues
    )
    
    $emailSection = ''

    Add-Type -AssemblyName System.Web

    $counter = 0

    foreach ($outputValue in $outputValues)
    {
        $rowStyle = if ($counter % 2 -eq 0) { "" } else { "background-color: #e1e3e8" }

        $tempRow = ""
        foreach ($headerKey in $outputHeaders.Keys)
        {
            $fieldValue = $outputValue[$headerKey] #Would need to change to something like $outputValue.psobject.Properties["Message"].Value if this changes to a pscustomobject
            #$fieldValue = $outputValue.psobject.Properties[$headerKey].Value
            if ($outputValue['Highlight'] -ne $null -and $outputValue['Highlight'].Contains($headerKey)) {
                $style = 'font-weight: bold; color: red;"'
                $rowStyle = "background-color: #FCCFC5"
            } else {
                $style = ''
            }

            $align = 'left'
            $temp = ''
            if ([decimal]::TryParse($fieldValue, [ref]$temp))
                { $align = 'right' }

            $fieldValue = [System.Web.HttpUtility]::HtmlEncode($fieldValue)

            $tempRow += '<td valign="top" style="border: 1px solid #CCCCCC;' + $style + '" align="' + $align +'">' + $fieldValue + '</td>'
        }

        $emailSection += "<tr style=""$rowStyle"">"
        $emailSection += $tempRow

        $counter++
        $emailSection += '</tr>'
    }

    return $emailSection
}