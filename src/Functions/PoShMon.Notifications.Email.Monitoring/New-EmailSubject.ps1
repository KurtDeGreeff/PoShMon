Function New-EmailSubject
{
    [CmdletBinding()]
    param(
        [hashtable]$PoShMonConfiguration,
        [object[]]$TestOutputValues
    )

    $issueCount = 0
    foreach ($outputValue in $TestOutputValues)
        { if (($outputValue.NoIssuesFound -eq $false))
            { $issueCount++ } }

    $subject = "[PoshMon] $($PoShMonConfiguration.General.EnvironmentName) Monitoring Results ($issueCount Issue(s) Found)"

    return $subject
}