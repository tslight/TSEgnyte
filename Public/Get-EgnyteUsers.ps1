function Get-EgnyteUsers {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[object]$Session=(Get-EgnyteSession),
	[int]$StartIndex=1,
	[array]$Users=@(),
	[Parameter(ParameterSetName="Filter")]
	[string]$Filter,
	[Parameter(ParameterSetName="UserName")]
	[string]$UserName,
	[Parameter(ParameterSetName="Email")]
	[string]$Email,
	[Parameter(ParameterSetName="ExternalId")]
	[string]$ExternalId
    )

    if ($UserName) {
	$Filter = "userName eq $UserName"
    } elseif ($Email) {
	$Filter = "email eq $Email"
    } elseif ($ExternalId) {
	$Filter = "externalId eq $ExternalId"
    }

    if ($Filter) {
	$Filter = [System.Web.HttpUtility]::UrlEncode($Filter)
	$Resource = "pubapi/v2/users?count=100&startIndex=$StartIndex&$Filter"
    } else {
	$Resource = "pubapi/v2/users?count=100&startIndex=$StartIndex"
    }

    $RequestArgs = @{
	Method = "Get"
	Session = $Session
	Resource = $Resource
    }

    try {
	$Response = New-EgnyteRequest @RequestArgs
	$msg = (
	    "Retrieved $StartIndex - $($StartIndex + 100) of $($Response.totalResults) results..."
	)
	Write-Host -Back Black -Fore Cyan $msg
	Write-Verbose $Response
    } catch {
	Write-Warning $_.InvocationInfo.ScriptName
	Write-Warning $_.InvocationInfo.Line
	Write-Warning $_.Exception.Message
	Write-Warning $Resource
    }

    if ($Response.resources -ne $Null) {
	$Users += $Response.resources
	$StartIndex += 100
	Get-EgnyteAllUsers -Session $Session -StartIndex $StartIndex -Users $Users
    } else {
	return $Users
    }
}
