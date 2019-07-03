function Delete-CachedObjects
{
    Param(
        [Parameter(ParameterSetName='url', Mandatory=$true)]    [string] $URLs,
        [Parameter(ParameterSetName='cpcode', Mandatory=$true)] [string] $CPCodes,
        [Parameter(ParameterSetName='tag', Mandatory=$true)]    [string] $Tags,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('Staging', 'Production')] $Network = 'production',
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'ccu',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Objects = @()
    if($URLs){
        if($URLs.Contains(",")) {
            $URLs = $URLs.Replace(" ","")
            $URLs = $URLs -split ","
        }
        $Objects += $URLs
    }
    if($CPCodes){
        if($CPCodes.Contains(",")) {
            $CPCodes = $CPCodes.Replace(" ","")
            $CPCodes = $CPCodes -split ","
        }
        $Objects += $CPCodes
    }
    if($Tags){
        if($Tags.Contains(",")) {
            $Tags = $Tags.Replace(" ","")
            $Tags = $Tags -split ","
        }
        $Objects += $Tags
    }
    $PostBody = @{ 'objects' = $Objects }
    $PostJson = $PostBody | ConvertTo-Json -Depth 100

    $Path = "/ccu/v3/delete/$($PSCmdlet.ParameterSetName)/$Network`?accountSwitchKey=$AccountSwitchKey"

    try
    {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -Body $PostJson
        return $Result
    }
    catch
    {
       throw $_.Exception 
    }
}

