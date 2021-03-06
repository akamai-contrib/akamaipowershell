function New-EdgeKVNamespace
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $Name,
        [Parameter(Mandatory=$true)]  [string] [ValidateSet('STAGING','PRODUCTION')] $Network,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/edgekv/v1/networks/$Network/namespaces?accountSwitchKey=$AccountSwitchKey"

    $BodyObj = @{
        name = $Name
    }
    $Body = $BodyObj | ConvertTo-Json

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.namespaces
    }
    catch {
        throw $_.Exception
    }
}