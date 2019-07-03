function Get-PapiCPCode
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $CPCode,
        [Parameter(Mandatory=$true)]  [string] $GroupId,
        [Parameter(Mandatory=$true)]  [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/papi/v1/cpcodes/$cpcodeId`?contractId=$ContractID&groupId=$GroupID&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}