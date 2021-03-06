﻿$version = "0.12.0"
$manifestPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath "\PoShMon.psd1"

Remove-Item -Path $manifestPath -ErrorAction SilentlyContinue

$description = "PoShMon is an open source PowerShell-based server and farm monitoring solution. It's an 'agent-less' monitoring tool, which means there's nothing that needs to be installed on any of the environments you want to monitor - you can simply run or schedule the script from a regular workstation and have it monitor a single server or group of servers, using PowerShell remoting. PoShMon is also able to monitor 'farm'-based products like SharePoint, in which multiple servers work together to provide a single platform.

Key Features
Some of the key features / benefits of PoShMon are:
- Agent-less Monitoring - nothing needs to be installed on the remote servers
- Core operating system and web-site monitoring
- Specialized SharePoint monitoring
- Supports frequent/critical as well as comprehensive daily monitoring
- Email, Pushbullet (mobile) and Office 365 Teams ('Chat-ops') notifications
- Provides a framework for 'self-healing' systems

For more information, documentation etc. visit https://github.com/HiltonGiesenow/PoShMon as well as the Samples folder within the module itself."

$releaseNotes = "
0.12.0
* Added Office Web Apps / Office Online Server monitoring
* Added some style to Email output
* Changed display to Hard Drive and Memory output
* Fixed bug in email footer for skipped tests

0.11.0
* Created 'Self-Healing' Framework into which custom scripts can be injected
* Added ability to skip auto-discovered Windows services
* Fixed bug where Pushbullet and Office 365 Teams were not showing Environment name
* Fixed bug in harddrive space percent test
* Fixed bug in cpu test for standalone 'minimal config test

0.10.1
* Added Proxy settings to enable PushBullet and 0365 Teams connectivity
* Introduced a 'minimum configuration' for local machine monitoring
* Fixed bug in SharePoint UPS Sync monitor
* Added Resolver for High CPU usage while SharePoint Search Index is running
* Improved Verbose output logging
* Added option for harddrive space to track by percent
* Add a check for any invalid TestsToSkip
* Fixed bug in Update-PoShMon

0.9.2
* Fixed bug in email output
* Fixed bug with not terminating Remote sessions correctly

0.9.1
* Fixed a bug crossing hour and day boundaries for Server Time test
* Fixed a bug with Services on server testing in non-SharePoint environments

0.9.0
* Added a Server Time test for servers drifting apart
* Add an 'update' notification for new versions of PoShMon
* Add an 'Update' command to make updating PoShMon easier
* Add Try..Catch error handling to each Test method
* Switched to dynamically invoking test methods by name
* Created a shared 'Core' monitoring function

0.8.3
* Reduced duplication in Test code for Stopwatch
* Fixed naming for 'Free Percent' column in Memory Test
* For 'Critical' (i.e. NotifyOnFailure) runs, set Email Priority to High if failure occurs
* For Exception notifications,  set Email Priority to High
* Convert all Tests that used a PSSession parameter to using PoShMonConfiguration - improves testability
* Added Unit Tests for every main Test-* function

0.8.2
* Added date to UserProfileSync output
* Added a function to initialise output for all Test methods
* Added PoShMon version to email output
* Added Farm Health Test (SharePoint) - not active

0.8.1
* Fixing a bug in the SharePoint UPS sync query for datetime

0.8.0
* Added User Profile Sync monitoring for SharePoint 2010/2013 FIM service
* Added CPU monitoring
* Added html encoding for Email notification
* Some unit test bug fixes and coverage work

0.7.0
* Added monitoring for server memory (free + total)
* Removed Credential for Pushbullet, using Header directly instead
"

New-ModuleManifest -Path $manifestPath -ModuleVersion $version -RootModule "PoShMon.psm1" -Guid '6e6cb274-1bed-4540-b288-95bc638bf679' -Author "Hilton Giesenow" -CompanyName "Experts Inside" -FunctionsToExport '*' -Copyright "2016 Hilton Giesenow, All Rights Reserved" -ProjectUri "https://github.com/HiltonGiesenow/PoShMon" -LicenseUri "https://github.com/HiltonGiesenow/PoShMon/blob/master/LICENSE" -Description $description -Tags 'Monitoring','Server','Farm','SharePoint' -ReleaseNotes $releaseNotes -Verbose

$t = Test-ModuleManifest -Path $manifestPath

$t

$t.ExportedCommands.Keys

#Remove-Module PoShMon