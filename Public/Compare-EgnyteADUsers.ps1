function Compare-EgnyteADUsers {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory,ValueFromPipeline)]
	[object]$User,
	[Parameter(Mandatory)]
	[string]$Instance
    )

    process {
	$Params = @{
	    MemberType = 'NoteProperty'
	    Name = 'Egnyte Instance'
	    Value = $Instance
	}
	$User | Add-Member @Params

	if ($ADUser = Get-ADUserBySam $User.UserName) {
	    $IsADUser = $True
	} elseif ($ADUser = Get-ADUserByEmail $User.Email) {
	    $IsADUser = $True
	} else {
	    $Name = "$($User.FirstName) $($User.LastName)"
	    try {
		if ($ADUser = Get-ADUserByName $Name) {
		    $IsADUser = $True
		} else {
		    $IsADUser = $False
		    Write-Warning "Cannot find $Name in AD."
		}
	    } catch {
		$IsADUser = $False
		Write-Warning "Cannot find $($User.UserName) in AD."
	    }
	}

	if ($ADUser -is [array]) {
	    $ADUser = $ADUser[0]
	}

	if ($ADUser) {
	    $msg = "Found $($ADUser.Name) in AD."
	    Write-Host -Back Black -Fore Cyan $msg
	}

	$ADProperties = @{
	    'AD User Found'	= $IsADUser
	    'AD UserName'	= $ADUser.SamAccountName
	    'AD Name'		= $ADUser.Name
	    'AD Email'		= $ADUser.EmailAddress
	    'AD Company'	= $ADUser.Company
	    'AD Department'	= $ADUser.Department
	    'AD Enabled'	= $ADUser.Enabled
	    'AD Last Active'	= ($ADUser.LastLogonDate -Split ' ')[0]
	}

	foreach ($Key in $ADProperties.Keys) {
	    $Params = @{
		MemberType = 'NoteProperty'
		Name = $Key
		Value = $ADProperties[$Key]
	    }
	    $User | Add-Member @Params
	}

	Write-Output $User
    }
}
