function Get-PropertyVersionXML
{
    Param(
      [Parameter(Mandatory=$true)]  [string] $GroupID,
      [Parameter(Mandatory=$true)]  [string] $ContractId,
      [Parameter(Mandatory=$true)]  [string] $PropertyId,
      [Parameter(Mandatory=$true)]  [string] $PropertyVersion,
      [Parameter(Mandatory=$false)] [switch] $XML,
      [Parameter(Mandatory=$false)] [string] $Section = 'papi',
      [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/properties/$PropertyId/versions/$PropertyVersion`?contractId=$ContractId&groupId=$GroupID"
    if($AccountSwitchKey)
    {
        $ReqURL += "&accountSwitchKey=$AccountSwitchKey"
    }
    
    try {
        if($XML)
        {
            $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -XML
        }
        else
        {
            $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
        }
        return $Result  
    }
    catch {
        return $_
    }
}

