function Get-GroupDetails
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $GroupName,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/papi/v1/groups?accountSwitchKey=$AccountSwitchKey"
    
    
    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.groups.items | where {$_.groupName -eq $GroupName} 
    }
    catch {
        throw $_.Exception
    }
}