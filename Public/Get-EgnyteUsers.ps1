function Get-EgnyteUsers {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory)]
	[object]$Session,
	[string]$Filter
    )

    $Users		= @()
    $HasContent		= $True
    $PageNumber		= 1
    $InitialResource	= "pubapi/v2/users?count=100&startIndex"

    Write-Verbose "Retrieving users from $($Session.base_uri). This may take some time..."

    while ($HasContent) {
	if ($Filter) {
	    $Resource = "$InitialResource=$PageNumber&$Filter"
	} else {
	    $Resource = "$InitialResource=$PageNumber"
	}
	$RequestArgs = @{
	    Method	= "Get"
	    Session	= $Session
	    Resource	= $Resource
	}

	$Page = New-EgnyteRequest @RequestArgs

	if ($Page.resources -ne $Null) {
	    foreach ($User in $Page) {
		$Users += $User.resources
	    }
	    $PageNumber += 100
	} else {
	    $HasContent = $False
	}
    }

    return $Users
}
