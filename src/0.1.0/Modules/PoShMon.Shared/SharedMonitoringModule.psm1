﻿Function Format-Gigs
{
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipeline)]$freeSpaceRaw
    )

    $gigsValue = ($freeSpaceRaw/1MB)
   
    return ("{0:F0}" -f $gigsValue) 
    #$([Math]::Round($disk.Size/1GB,2))
}

Function Connect-RemoteSession
{
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true)][string]$ServerName,
        [string]$ConfigurationName = $null
    )

    if ($ConfigurationName -ne $null)
        { $remoteSession = New-PSSession -ComputerName $ServerName -ConfigurationName $ConfigurationName }
    else
        { $remoteSession = New-PSSession -ComputerName $ServerName }

    return $remoteSession
}

Function Disconnect-RemoteSession
{
    [cmdletbinding()]
    param(
        $RemoteSession
    )

    Remove-PSSession $RemoteSession
}

Function Get-EmailOutput
{
    [cmdletbinding()]
    param(
        $Output
    )

    $emailBody += '<p><h1>' + $Output.SectionHeader + '</h1>'
    $emailBody += '<table border="1"><thead><tr>'

    foreach ($headerKey in $output.OutputHeaders.Keys)
    {
        $header = $output.OutputHeaders[$headerKey]
        $emailBody += '<th align="left">' + $header + '</th>'
    }

    $emailBody += '</tr></thead><tbody>'
    
    foreach ($outputValue in $output.OutputValues)
    {
        $emailBody += '<tr>'

        foreach ($headerKey in $output.OutputHeaders.Keys)
        {
            $fieldValue = $outputValue[$headerKey]
            if ($outputValue['Highlight'] -ne $null -and $outputValue['Highlight'].Contains($headerKey)) {
                $style = ' style="font-weight: bold; color: red"'
            } else {
                $style = ''
            }

            $align = 'left'
            $temp = ''
            if ([decimal]::TryParse($fieldValue, [ref]$temp))
                { $align = 'right' }

            $emailBody += '<td valign="top"' + $style + ' align="' + $align +'">' + $fieldValue + '</td>'
        }

        $emailBody += '</tr>'
    }

    $emailBody += '</tbody></table>'

    return $emailBody
}

Function Get-EmailOutputGroup
{
    [cmdletbinding()]
    param(
        $output
    )

    $emailBody += '<p><h1>' + $Output.SectionHeader + '</h1>'
    $emailBody += '<table border="1">'
    
    foreach ($groupOutputValue in $output.OutputValues)
    {
        $emailBody += '<thead><tr><th align="left" colspan="' + $output.OutputHeaders.Keys.Count + '"><h2>' + $groupOutputValue.GroupName + '</h2></th></tr>'

        $emailBody += "<tr>"
        foreach ($headerKey in $output.OutputHeaders.Keys)
        {
            $header = $output.OutputHeaders[$headerKey]
            $emailBody += '<th align="left">' + $header + '</th>'
        }

        $emailBody += '</tr></thead><tbody>'
    
        foreach ($groupItemOutputValue in $groupOutputValue.GroupOutputValues)
        {
            $emailBody += '<tr>'

            foreach ($headerKey in $output.OutputHeaders.Keys)
            {
                $fieldValue = $groupItemOutputValue[$headerKey]

                if ($groupItemOutputValue['Highlight'] -ne $null -and $groupItemOutputValue['Highlight'].Contains($headerKey)) {
                    $style = ' style="font-weight: bold; color: red"'
                } else {
                    $style = ''
                }

                $emailBody += '<td valign="top"' + $style + '>' + $fieldValue + '</td>'
            }

            $emailBody += '</tr>'
        }
    }

    $emailBody += '</tbody></table>'

    return $emailBody
}

Function Get-EmailHeader
{
    [CmdletBinding()]
    param(
        [string]$ReportTitle = "PoShMon Monitoring Report"
    )

    $emailBody = '<head><title>' + $ReportTitle + '</title>
</head>
<body>
<h1>' + $ReportTitle + '</h1>'

    return $emailBody;

}

Function Get-EmailFooter
{
    [CmdletBinding()]
    param(
    )

        $emailBody = '</body>
'
    return $emailBody;
}