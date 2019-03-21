function Get-EgnyteADUserInfo {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory)]
	[System.IO.FileInfo]$InputCsv,
	[System.IO.FileInfo]$ExportCsv=".\EgnyteADInfo.csv"
    )

    $EmailAddresses = Get-CsvColumn -Csv $InputCsv -Column 'email'

    $ADEgnyteUsers = @()

    foreach ($Addr in $EmailAddresses) {
	$msg = "Getting AD user with $Addr email address..."
	Write-Host -Back Black -Fore Magenta $msg

	$Params = @{
	    Filter = {
		(EmailAddress -eq $Addr) -Or
		(mail -eq $Addr) -Or
		(UserPrincipalName -eq $Addr)
	    }
	    Server = $ADGlobalCatalog
	    Properties = @('EmailAddress')
	}

	if ($ADUser = Get-ADUser @Params | Get-ADUserAllProperties) {
	    $msg = "Getting Egnyte properties for $(ADUser.Name)..."
	    Write-Host -Back Black -Fore Magenta $msg
	    $EgnyteUser = Get-EgnyteADUser $ADUser
	} else {
	    $msg = "Couldn't find AD user for $Addr email address."
	    Write-Warning $msg
	    $msg = "Getting Egnyte properties for $Addr..."
	    Write-Host -Back Black -Fore Magenta $msg
	    $EgnyteUser = Get-EgnyteUser -Email $Addr
	}

	if ($EgnyteUser) {
	    $msg = "Found $($EgnyteUser.name)."
	    Write-Host -Back Black -Fore Cyan $msg
	} else {
	    $msg = "Failed to find Egnyte Properties for $($ADUser.Name)."
	    Write-Warning $msg
	}

	$ADEgnyteUser			= [PSCustomObject]@{
	    'AD Name'			= $ADUser.Name
	    'Egnyte Name'		= $Egnyte.username
	    'AD Email'			= $ADUser.EmailAddress
	    'Egnyte UPN'		= $Egnyte.userPrincipalName
	    'AD Company'		= $ADUser.Company
	    'AD Department'		= $ADUser.Department
	    'AD Enabled'		= $ADUser.Enabled
	    'Egnyte Active'		= $Egnyte.active
	    'Egnyte Account Type'	= $Egnyte.userType
	    'Egnyte Locked'		= $Egnyte.locked
	    'Egnyte Last Active'	= $Egnyte.lastActiveDate
	}

	$ADEgnyteUsers += $ADEgnyteUser
    }

    return $ADEgnyteUsers
}
