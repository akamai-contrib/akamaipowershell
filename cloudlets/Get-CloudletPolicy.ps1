function Get-CloudletPolicy
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PolicyID,
        [Parameter(Mandatory=$false)] [string] $Section = 'cloudlets',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/cloudlets/api/v2/policies/$PolicyID`?accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
        return $Result
    }
    catch {
        return $_ 
    }
}