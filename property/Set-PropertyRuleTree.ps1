Function Set-PropertyRuleTree
{
    Param(
        [Parameter(ParameterSetName="name", Mandatory=$true)]  [string] $PropertyName,
        [Parameter(ParameterSetName="id", Mandatory=$true)]  [string] $PropertyId,
        [Parameter(Mandatory=$true)]  [string] $PropertyVersion,
        [Parameter(Mandatory=$true)]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $SetRuleFormat,
        [Parameter(Mandatory=$false)] [switch] $DryRun,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('fast','full')]  $ValidateMode,
        [Parameter(Mandatory=$false)] [switch] $ValidateRules,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $DryRunString = $DryRun.IsPresent.ToString().ToLower()
    if(!$DryRun){ $DryRunString = '' }
    $ValidateRulesString = $ValidateRules.IsPresent.ToString().ToLower()
    if(!$ValidateRules){ $ValidateRulesString = '' }

    # Find property if user has specified PropertyName or version = "latest"
    if($PropertyName){
        try{
            $Property = Find-Property -PropertyName $PropertyName -latest -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
            $PropertyID = $Property.propertyId
            if($PropertyID -eq ''){
                throw "Property '$PropertyName' not found"
            }
        }
        catch{
            throw $_.Exception
        }
    }

    if($PropertyVersion.ToLower() -eq "latest"){
        try{
            if($PropertyName){
                $PropertyVersion = $Property.propertyVersion
            }
            else{
                $Property = Get-Property -PropertyId $PropertyID -GroupID $GroupID -ContractId $ContractId -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
                $PropertyVersion = $Property.latestVersion
            }
        }
        catch{
            throw $_.Exception
        }
    }

    $Path = "/papi/v1/properties/$PropertyId/versions/$PropertyVersion/rules?validateRules=$ValidateRulesString&validateMode=$ValidateMode&dryRun=$DryRunString&contractId=$ContractId&groupId=$GroupID&accountSwitchKey=$AccountSwitchKey"

    if($SetRuleFormat){
        $AdditionalHeaders = @{
            'Content-Type' = "application/vnd.akamai.papirules.$RuleFormat+json"
        }
    }

    try
    {
        $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch
    {
        throw $_.Exception
    }
}