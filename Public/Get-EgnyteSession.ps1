function Get-EgnyteSession {
    [cmdletbinding()]
    Param (
	[string]$Instance=$(Read-Host "Enter your Egnyte instance name"),
	[string]$Username=$(Read-Host "Enter an Egnyte admin username"),
	[System.IO.FileInfo]$JsonSessionsDir=$JsonSessionsDir
    )

    process {
	$Path = "$JsonSessionsDir\$Instance.$Username.json"
	try {
	    $Session = Get-Content $Path -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
	    Write-Verbose "Successfully authenticated using $Path."
	} catch [System.Management.Automation.ItemNotFoundException] {
	    Write-Warning "Cannot find cached $Instance.$Username session. Creating new one..."
	    try {
		$Session = New-EgnyteSession -Instance $Instance -Username $Username
		Write-Verbose "Successfully created new $Instance.$Username session."
	    } catch {
		throw
	    }
	} catch [System.ArgumentException] {
	    Write-Warning "Cannot parse $Path as valid json. Creating new one..."
	    try {
		$Session = New-EgnyteSession -Instance $Instance -Username $Username
		Write-Verbose "Successfully created new $Instance.$Username session."
	    } catch {
		throw
	    }
	}
	return $Session
    }
}
