#************************************************************************
#
#	Name: AkamaiPowershell.psm1
#	Author: S Macleod
#	Purpose: Standard methods to interact with Luna API
#	Date: 21/11/18
#	Version: 3 - Moved to .edgerc support
#
#************************************************************************

$Directories = Get-ChildItem $PSScriptRoot -exclude examples,pester | Where { $_.PSIsContainer }
$PS1Files = @()
$Directories | foreach { $PS1Files += Get-ChildItem "$_\*.ps1" }
$PS1Files | foreach { . $_.FullName }
$PS1Files | foreach { Export-ModuleMember $_.BaseName }

# Alias all List- cmdlets to Get- also for ease of use
$PS1Files | Where {$_.Name.StartsWith('List-')} | foreach {
    $CmdletName = $_.BaseName
    $GetAlias = $CmdletName.Replace("List-", "Get-")
    Set-Alias -Name $GetAlias -Value $CmdletName
    Export-ModuleMember -Function $CmdletName -Alias $GetAlias
}