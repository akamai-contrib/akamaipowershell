#************************************************************************
#
#	Name: List-LDSConfigsForCPCodes
#	Author: S Macleod
#	Purpose: Polls LDS API for find live configs for given cp codes
#	Date: 04/02/2019
#	Version: 1 - Initial
#
#************************************************************************

Param(
    [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
    [Parameter(Mandatory=$false)] [string] $Section = 'default',
    [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
)

$Results = New-Object -TypeName System.Collections.ArrayList
$LogSources = List-LDSLogSources -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
Write-Host "Found $($LogSources.count) sources to process"
for($i = 0; $i -lt $LogSources.count; $i++)
{
    $PercentComplete = ($i / $LogSources.Count * 100)
    $PercentComplete = [math]::Round($PercentComplete)
    Write-Progress -Activity "Listing properties..." -Status "$PercentComplete% Complete:" -PercentComplete $PercentComplete;

    $Config = List-LDSLogConfigurationsForID -Section $Section -logSourceID $LogSources[$i].id
    if($null -ne $Config)
    {
        $Results.Add($Config) | Out-Null
    }
}

return $Results


