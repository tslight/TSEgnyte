function Get-EgnytePaidDisabledUsers {
    <#
.SYNOPSIS
Find disabled AD users that we are still paying for.

.DESCRIPTION
Compare disabled User_Egnyte AD group members to active Egnyte users with the
roles power or admin.

.PARAMETER Session
A valid Egnyte Session.

.INPUTS
A valid Egnyte Session.

.OUTPUTS
Egnyte users that have active accounts who are disabled in AD.

.LINK
https://developers.egnyte.com/docs/User_Management_API_Documentation
#>
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[object]$Session=(Get-EgnyteSession)
    )

    Write-Verbose "Getting all members of AD Egnyte group..."

    $ADGroup = Get-ADGroupMembersByName 'Users_Egnyte'

    $DisabledADUsers = $ADGroup | Where-Object {
	$_.Enabled -eq $False
    }

    $DisabledADUsers | Get-EgnyteADUser -Session $Session | Where-Object {
	($_.active -eq $True) -and ($_.userType -eq 'power' -or $_.userType -eq 'admin')
    }
}
