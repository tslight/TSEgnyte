function Get-EgnyteADUsersFromEmail {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory,ValueFromPipeline)]
	[mailaddress]$EmailAddress,
	[object]$Session=(Get-EgnyteSession)
    )

    begin {
	Write-Verbose "Creating new object based on AD and Egnyte properties..."
    }

    process {
	$Email = $EmailAddress.Address
	$msg = "Getting AD user with $Email email address..."
	Write-Host -Back Black -Fore Magenta $msg

	if ($ADUser = Get-ADUsersByEmail $Email) {
	    $IsADUser = $True
	    $msg = "Found $($ADUser.name) in AD."
	    Write-Host -Back Black -Fore Cyan $msg
	    $msg = "Getting Egnyte properties for $($ADUser.Name)..."
	    Write-Host -Back Black -Fore Magenta $msg
	    if ($ADUser -is [array]) { $ADUser = $ADUser[0] }
	    $EgnyteUser = Get-EgnyteADUser $ADUser -Session $Session
	} else {
	    $IsADUser = $False
	    $msg = "Couldn't find AD user for $Email email address."
	    Write-Warning $msg
	    $msg = "Getting Egnyte properties for $Email..."
	    Write-Host -Back Black -Fore Magenta $msg
	    $EgnyteUser = Get-EgnyteUsers -Email $Email -Session $Session
	}

	if ($EgnyteUser) {
	    $IsEgnyteUser = $True
	    $msg = "Found $($EgnyteUser.userName) in Egnyte."
	    Write-Host -Back Black -Fore Cyan $msg
	    if ($EgnyteUser.lastActiveDate) {
		$EgnyteLastActiveDate = $EgnyteUser.lastActiveDate | Get-Date -UFormat '%Y-%m-%d'
	    }
	} else {
	    $IsEgnyteUser = $False
	    $msg = "Failed to find Egnyte Properties for $Email."
	    Write-Warning $msg
	}

	[PSCustomObject]@{
	    'Found in AD'               = $IsADUser
	    'Found in Egnyte'           = $IsEgnyteUser
	    'Egnyte Email'              = $Email
	    'Egnyte UPN'		= $EgnyteUser.userPrincipalName
	    'Egnyte Name'		= $EgnyteUser.userName
	    'AD Name'			= $ADUser.Name
	    'AD Email'			= $ADUser.EmailAddress
	    'AD Company'		= $ADUser.Company
	    'AD Department'		= $ADUser.Department
	    'AD Enabled'		= $ADUser.Enabled
	    'Egnyte Active'		= $EgnyteUser.active
	    'Egnyte Account Type'	= $EgnyteUser.userType
	    'Egnyte Locked'		= $EgnyteUser.locked
	    'Egnyte Last Active'	= $EgnyteLastActiveDate
	}
    }

    end {
	Write-Verbose "Finished creating new object based on AD and Egnyte properties..."
    }
}
