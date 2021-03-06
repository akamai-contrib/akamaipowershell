function Get-IDMRole
{
    Param(
        [Parameter(Mandatory=$false)] [string] $RoleID,
        [Parameter(Mandatory=$false)] [switch] $Actions,
        [Parameter(Mandatory=$false)] [switch] $GrantedRoles,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $ActionsString = $Actions.IsPresent.ToString().ToLower()
    $GrantedRolesString = $GrantedRoles.IsPresent.ToString().ToLower()
    if(!$Actions){ $ActionsString = '' }
    if(!$GrantedRoles){ $GrantedRolesString = '' }

    $Path = "/identity-management/v2/user-admin/roles/$RoleID`?actions=$ActionsString&grantedRoles=$GrantedRolesString&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}