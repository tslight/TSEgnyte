function New-EgnyteSession {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[string]$Username=$(Read-Host "Enter your Egnyte Administrator Username"),
	[object]$Password=$(Read-Host -AsSecureString "Enter your Egnyte Administrator Password"),
	[string]$Instance=$(Read-Host "Enter the name of the Egnyte instance you'd like to query"),
	[string]$APIKey=$EgnyteAPIKey,
	[System.IO.FileInfo]$JsonSessionDir=$JsonSessionDir
    )

    Add-Type -AssemblyName System.Web # suddenly stopped loading by default

    $BTSR     = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
    $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BTSR)
    $URL      = "https://$Instance.egnyte.com"
    $Resource = "/puboauth/token?grant_type=password&username=$Username&password=$Password&client_id=$APIKey"
    $Resource = [System.Web.HttpUtility]::UrlEncode($Resource)
    $Uri      = "$URL/$Resource"

    try {
	$Session = Invoke-RestMethod -Method Post -Uri $Uri
	if ($Session) {
	    $Client = @{
		"username"   = $Username
		"access_key" = $APIKey
		"token"      = $Session.access_token
		"token_type" = $Session.token_type
		"expires_in" = $Session.expires_in
		"instance"   = $Instance
		"base_uri"   = $URL
	    }
	    $Client | ConvertTo-Json | Out-File -Encoding UTF8 "$JsonSessionsDir\$Instance.$Username.json"
	    return $Client
	} else {
	    throw "Failed to authenticate to Egnyte."
	}
    } catch {
	Write-Warning $_
	throw $_
    }
}
