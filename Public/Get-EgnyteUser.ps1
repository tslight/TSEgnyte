function Get-EgnyteUser {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory,ValueFromPipeline)]
	[Microsoft.ActiveDirectory.Management.ADUser]$ADUser,
	[Parameter(Mandatory)]
	[object]$Session
    )

    begin {
	$EgnyteUsers = @()
    }

    process {
	$Email		= $ADUser.EmailAddress
	$UPN            = $ADUser.UserPrincipalName
	$SID		= $ADUser.SID
	$Resource	= "pubapi/v2/users?filter"

	if ($Email) {
	    $Query = "email eq $Email"
	} elseif ($UPN) {
	    $Query = "userPrincipalName eq $UPN"
	} elseif ($SID) {
	    $Query = "externalId eq $SID"
	}

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
	}

	$EgnyteUsers += $EgnyteUser.resources
    }

    end {
	return $EgnyteUsers
    }
}
