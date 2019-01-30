function Invalidate-CCUCacheByCPCode
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $CPCode,
        [Parameter(Mandatory=$false)] [string] $Network = 'production',
        [Parameter(Mandatory=$false)] [string] $Section = 'ccu'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $PostBody = @{ objects = @("$CPCode") }
    $PostJson = $PostBody | ConvertTo-Json -Depth 100
    $ReqURL = "https://" + $Credentials.host + "/ccu/v3/invalidate/cpcode/$Network"

    $Result = Invoke-AkamaiOPEN -Method POST -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -Body $PostJson
    return $Result
}

