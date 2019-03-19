function Get-EgnyteADUser {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory,ValueFromPipeline)]
	[Microsoft.ActiveDirectory.Management.ADUser]$ADUser,
	[object]$Session=(Get-EgnyteSession)
    )

    begin {
	$EgnyteUsers = @()
    }

    process {
	$Email		= $ADUser.EmailAddress
	$Sam            = $ADUser.SamAccountName
	$SID		= $ADUser.SID
	$Resource	= "pubapi/v2/users?filter"

	if ($Email) {
	    $Query = "email eq $Email"
	} elseif ($UPN) {
	    $Query = "userName eq $Sam"
	} elseif ($SID) {
	    $Query = "externalId eq $SID"
	} else {
	    Write-Warning "Cannot find email, userName or externalId."
	    continue
	}

	$Query = [System.Web.HttpUtility]::UrlEncode($Query)

	$Resource = "$Resource=$Query"

	$RequestArgs = @{
	    Method	= "Get"
	    Session	= $Session
	    Resource	= $Resource
	}

	try {
	    $EgnyteUser = New-EgnyteRequest @RequestArgs
	} catch {
	    Write-Warning $_.InvocationInfo.ScriptName
	    Write-Warning $_.InvocationInfo.Line
	    Write-Warning $_.Exception.Message
	    Write-Warning $Resource
	}

	$EgnyteUsers += $EgnyteUser.resources
    }

    end {
	return $EgnyteUsers
    }
}
