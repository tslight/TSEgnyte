function Get-EgnyteUsers {
    <#
    .SYNOPSIS
    Brief description

    .DESCRIPTION
    Longer description

    .PARAMETER Foobar
    Descriptions of parameter Foobar

    .INPUTS
    Types of objects that can be piped to the function

    .OUTPUTS
    Type of the objects that the function returns

    .EXAMPLE
    Actual example

    .NOTES
    Additional notes

    .LINK
    Related URL links
    #>

    [CmdletBinding(SupportsShouldProcess,DefaultParameterSetName="Filter")]
    Param (
	[object]$Session=(Get-EgnyteSession),
	[int]$StartIndex=1,
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
	$SanitisedFilter = [System.Web.HttpUtility]::UrlEncode($Filter)
	$Resource = "pubapi/v2/users?count=100&startIndex=$StartIndex&filter=$SanitisedFilter"
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
	if ($Response.totalResults -gt 100) {
	    $msg = (
		"Retrieved $StartIndex - $($StartIndex + 100) of $($Response.totalResults) results..."
	    )
	} else {
	    $msg = "Retrieved $($Response.totalResults) results."
	}
	Write-Verbose $msg
	Write-Verbose $Response
    } catch {
	Write-Warning $_.InvocationInfo.ScriptName
	Write-Warning $_.InvocationInfo.Line
	Write-Warning $_.Exception.Message
	Write-Warning $Resource
    }

    if ($Response.resources -ne $Null) {
	$Response.resources
	if (($StartIndex + 100) -le $Response.totalResults) {
	    $StartIndex += 100
	    $Params = @{
		Session = $Session
		StartIndex = $StartIndex
		Filter = $Filter
	    }
	    Get-EgnyteUsers @Params
	}
    }
}
