﻿Function Get-EventLogItemsBySeverity
{
    param (
        [string]$ComputerName,
        [string]$SeverityCode = "Warning",
        $WmiStartDate
    )

   $events = Get-WmiObject win32_NTLogEvent -ComputerName $ComputerName -filter "(logfile='Application') AND (Type ='$severityCode') And TimeGenerated > '$wmiStartDate'"

   return $events
}

Function Get-GroupedEventLogItemsBySeverity
{
    param (
        [string]$ComputerName,
        [string]$SeverityCode = "Warning",
        $WmiStartDate
    )

   $events = Get-WmiObject win32_NTLogEvent -ComputerName $ComputerName -filter "(logfile='Application') AND (Type ='$severityCode') And TimeGenerated > '$wmiStartDate'" | Group-Object EventCode, Message

   return $events
}

Function Test-EventLogs
{
    [CmdletBinding()]
    param (
        [string[]]$ServerNames = ('ZAMGNTSPAPP1', 'ZAMGNTSPWEB1', 'ZAMGNTSPWEB2'),
        [int]$MinutesToScanHistory = 1440, # one day
        [string]$SeverityCode = 'Critical',
        [hashtable]$EventIDIgnoreList = @{}
    )
   
    $NoIssuesFound = $true
    $outputHeaders = @{ 'EventID' = 'Event ID'; 'InstanceCount' = 'Count'; 'Source' = 'Source'; 'User' = 'User'; 'Timestamp' = 'Timestamp'; 'Message' ='Message' }
    $outputValues = @()

    $wmiStartDate = (Get-Date).AddMinutes(-$MinutesToScanHistory) #.ToUniversalTime()
    $wmidate = new-object -com Wbemscripting.swbemdatetime
    $wmidate.SetVarDate($wmiStartDate, $true)
    $wmiStartDateWmi = $wmidate.value

    Write-Verbose ($SeverityCode + " Event Log Issues")

    foreach ($serverName in $ServerNames)
    {
        $itemOutputValues = @()
        
        $eventLogEntryGroups = Get-GroupedEventLogItemsBySeverity -ComputerName $serverName -SeverityCode $SeverityCode -WmiStartDate $wmiStartDateWmi

        Write-Verbose $serverName

        if ($eventLogEntryGroups.Count -gt 0)
        {
            foreach ($eventLogEntryGroup in $eventLogEntryGroups)
            {
                $currentEntry = $eventLogEntryGroup.Group[0]

                if ($EventIDIgnoreList.Count -eq 0 -or $EventIDIgnoreList.ContainsKey($currentEntry.EventCode) -eq $false)
                {
                    $NoIssuesFound = $false

                    Write-Verbose ($currentEntry.EventCode.ToString() + ' (' + $eventLogEntryGroup.Count + ', ' + $currentEntry.SourceName + ', ' + $currentEntry.User + ') : ' + $currentEntry.ConvertToDateTime($currentEntry.TimeGenerated) + ' - ' + $currentEntry.Message)
                
                    $outputItem = @{
                                    'EventID' = $currentEntry.EventCode;
                                    'InstanceCount' = $eventLogEntryGroup.Count;
                                    'Source' = $currentEntry.SourceName;
                                    'User' = $currentEntry.User;
                                    'Timestamp' = $currentEntry.ConvertToDateTime($currentEntry.TimeGenerated);
                                    'Message' = $currentEntry.Message
                                }

                    $itemOutputValues += $outputItem
                }
            }

            $groupedoutputItem = @{
                                'GroupName' = $serverName
                                'GroupOutputValues' = $itemOutputValues
                            }

            $outputValues += $groupedoutputItem
        }

        if ($NoIssuesFound)
        {
            Write-Verbose "`tNone"
            $groupedoutputItem = @{
                                'GroupName' = $serverName
                                'GroupOutputValues' = @()
                            }

            $outputValues += $groupedoutputItem
        }
    }

    return @{
        "NoIssuesFound" = $NoIssuesFound;
        "OutputHeaders" = $outputHeaders;
        "OutputValues" = $outputValues
        }
}

Function Test-DriveSpace
{
    [CmdletBinding()]
    param (
        [string[]]$ServerNames
    )

    $threshhold = 10000

    $NoIssuesFound = $true
    $outputHeaders = @{ 'DriveLetter' = 'Drive Letter'; 'TotalSpace' = 'Total Space (GB)'; 'FreeSpace' = 'Free Space (GB)' }
    $outputValues = @()

    Write-Verbose "Harddrive Space Review"

    foreach ($serverName in $ServerNames)
    {
        Write-Verbose $serverName

        $itemOutputValues = @()
    
        $serverDriveSpace = Get-WmiObject win32_logicaldisk -Computername $serverName

        foreach ($drive in ($serverDriveSpace | Where DriveType -eq 3))
        {
            $totalSpace = $drive.Size | Format-Gigs 
            $freeSpace = $drive.FreeSpace | Format-Gigs 
            $highlight = @()

            if ([int]$freeSpace -lt $threshhold)
            {
                $NoIssuesFound = $false
                $highlight += "FreeSpace"
            }

            Write-Verbose ("`t" + $drive.DeviceID + " : " + $totalSpace + " : " + $freeSpace)

            $outputItem = @{
                'DriveLetter' = $drive.DeviceID;
                'TotalSpace' = $totalSpace;
                'FreeSpace' = $freeSpace;
                'Highlight' = $highlight
            }

            $itemOutputValues += $outputItem
        }

        $groupedoutputItem = @{
                    'GroupName' = $serverName
                    'GroupOutputValues' = $itemOutputValues
                }

        $outputValues += $groupedoutputItem
    }

    return @{
        "NoIssuesFound" = $NoIssuesFound;
        "OutputHeaders" = $outputHeaders;
        "OutputValues" = $outputValues
        }
}

Function Invoke-OSMonitoring
{
    [CmdletBinding()]
    Param(
        #[parameter(Mandatory=$true, HelpMessage=”Path to file”)]
        [int]$MinutesToScanHistory = 15,
        [string[]]$ServerNames = ('ZAMGNTSPAPP1', 'ZAMGNTSPWEB1', 'ZAMGNTSPWEB2'),
        [string[]]$MailToList = ("hilton@giesenow.com", "hilton.giesenow@maitlandgroup.co.za"),
        [string[]]$EventLogCodes = 'Critical',
        [hashtable]$EventIDIgnoreList = @{},
        [bool]$SendEmail = $true
    )

    $emailBody = Get-EmailHeader
    $NoIssuesFound = $true 

    # Event Logs
    foreach ($eventLogCode in $EventLogCodes)
    {
        $eventLogOutput = Test-EventLogs -ServerNames $ServerNames -MinutesToScanHistory $MinutesToScanHistory -SeverityCode $eventLogCode -EventIDIgnoreList $EventIDIgnoreList
        $emailBody += Get-EmailOutputGroup -SectionHeader ($eventLogCode + " Event Log Entries") -output $eventLogOutput
        $NoIssuesFound = $NoIssuesFound -and $eventLogOutput.NoIssuesFound
    }

    # Drive Space
    $driveSpaceOutput = Test-DriveSpace -ServerNames $ServerNames
    $emailBody += Get-EmailOutputGroup -SectionHeader "Server Drive Space" -output $driveSpaceOutput
    $NoIssuesFound = $NoIssuesFound -and $driveSpaceOutput.NoIssuesFound

    $emailBody += Get-EmailFooter

    if ($NoIssuesFound)
    {
        Write-Verbose "No major issues encountered, skipping email"
    } else {
        if ($SendEmail)
        {
            Send-MailMessage -Subject "[PoshMon Monitoring] Monitoring Results" -Body $emailBody -BodyAsHtml -To $MailToList -From "SPMonitoring@maitlandgroup.co.za" -SmtpServer "ZAMGNTEXCH01.ZA.GROUP.COM"
        } 
    }
}