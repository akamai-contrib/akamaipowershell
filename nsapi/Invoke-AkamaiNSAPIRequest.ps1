function Invoke-AkamaiNSAPIRequest {
    Param(
        [Parameter(Mandatory=$true)] [string] $Path,
        [Parameter(Mandatory=$true)] [string] [ValidateSet('delete', 'dir', 'download', 'du', 'list', 'mkdir', 'ntime', 'quick-delete', 'rename', 'rmdir', 'stat', 'symlink', 'upload')] $Action,
        [Parameter(Mandatory=$true)] [Hashtable] $AdditionalOptions,
        [Parameter(Mandatory=$false)] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $AuthFile = "~/.akamai-cli/.netstorage/auth",
        [Parameter(Mandatory=$false)] [string] $Section = "default"
    )

    # Get credentials from Auth File
    if(!(Test-Path $AuthFile)){
        throw "Error: Auth File $AuthFile not found"
    }

    $Config = Get-Content $AuthFile
    if("[$Section]" -notin $Config){
        throw "Error: Config section [$Section] not found in $EdgeRCFile"
    }

    $ConfigIndex = [array]::indexof($Config,"[$Section]")
    $SectionArray = $Config[$ConfigIndex..($ConfigIndex + 5)]
    $SectionArray | ForEach-Object {
        if($_.ToLower().StartsWith("key")) { $Key = $_.Replace(" ","").SubString($_.IndexOf("=")) }
        if($_.ToLower().StartsWith("id")) { $ID = $_.Replace(" ","").SubString($_.IndexOf("=")) }
        if($_.ToLower().StartsWith("group")) { $Group = $_.Replace(" ","").SubString($_.IndexOf("=")) }
        if($_.ToLower().StartsWith("host")){ $NSHost = $_.Replace(" ","").SubString($_.IndexOf("=")) }
        if($_.ToLower().StartsWith("cpcode")){ $CPCode = $_.Replace(" ","").SubString($_.IndexOf("=")) }
    }

    $NSHost = "https://$NSHost"

    if(!$key -or !$ID -or !$Group -or !$NSHost -or !$CPCode){
        throw "Error: Some necessary auth elements missing. Please check your auth file"
    }

    # Check for Proxy Env variable and use if present
    if($null -ne $ENV:https_proxy)
    {
        $UseProxy = $true
    }

    #Prepend path with / and add CP Code
    if(!($Path.StartsWith("/"))) {
        $Path = "/$Path"
    }
    if(!($Path.StartsWith("/$CPCode/"))) {
        $Path = "/$CPCode$Path"
    }

    $Headers = @{}

    $EncodedPath = [System.Web.HttpUtility]::UrlEncode($Path)

    # Action Header
    $Options = @{
        'version' = '1'
        'action' = $Action
    }
    if($AdditionalOptions){
        $Options += $AdditionalOptions
    }

    $Options.Keys | foreach {
        $ActionHeader += "$_=$($Options[$_])&"
    }

    if($ActionHeader.EndsWith("&")){
        $ActionHeader = $ActionHeader.Substring(0,$ActionHeader.LastIndexOf("&"))
    }
    $Headers['X-Akamai-ACS-Action'] = $ActionHeader

    #GUID for request signing
    $Nonce = Get-RandomString -Length 20 -Hex

    # Generate X-Akamai-ACS-Auth-Data variable
    $Version = 5
    $EpochTime = [Math]::Floor([decimal](Get-Date(Get-Date).ToUniversalTime()-uformat "%s"))
    $AuthDataHeader = "$Version, 0.0.0.0, 0.0.0.0, $EpochTime, $Nonce, $ID"
    $Headers['X-Akamai-ACS-Auth-Data'] = $AuthDataHeader

    # Create sign-string for encrypting, reuse shared Crypto
    $SignString = "$Path`nx-akamai-acs-action:$ActionHeader`n"
    $EncryptMessage = $AuthDataHeader + $SignString
    $Signature = Crypto -secret $Key -message $EncryptMessage
    $Headers['X-Akamai-ACS-Auth-Sign'] = $Signature

    # Determine HTTP Method from Action
    Switch($Action) {
        'delete'       { $Method = "PUT"}
        'dir'          { $Method = "GET"}
        'download'     { $Method = "GET"}
        'du'           { $Method = "GET"}
        'list'         { $Method = "GET"}
        'mkdir'        { $Method = "PUT"}
        'mtime'        { $Method = "POST"}
        'quick-delete' { $Method = "POST"}
        'rename'       { $Method = "POST"}
        'rmdir'        { $Method = "POST"}
        'stat'         { $Method = "GET"}
        'symlink'      { $Method = "POST"}
        'upload'       { $Method = "PUT"}
    }

    # Set ReqURL from NSAPI hostname and supplied path
    $ReqURL = $NSHost + $Path

    # Do it.
    if ($Method -eq "PUT" -or $Method -eq "POST") {
        try {
            if ($Body) {
                if($UseProxy){
                    $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -ContentType 'application/json' -Body $Body -Proxy $ENV:https_proxy
                }
                else {
                    $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -ContentType 'application/json' -Body $Body
                }
                
            }
            else {
                if($UseProxy) {
                    $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -ContentType 'application/json' -Proxy $ENV:https_proxy
                }
                else {
                    $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -ContentType 'application/json'
                }
            }
        }
        catch {
            throw $_
        }
    }
    else {
        try {
            if($UseProxy) {
                $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -ContentType 'application/json' -MaximumRedirection 0 -ErrorAction Stop -Proxy $ENV:https_proxy
            }
            else {
                $Response = Invoke-RestMethod -Method $Method -Uri $ReqURL -Headers $Headers -ContentType 'application/json' -MaximumRedirection 0 -ErrorAction Stop
            }
        }
        catch {
            throw $_
        }
    }
    
    return $Response
}