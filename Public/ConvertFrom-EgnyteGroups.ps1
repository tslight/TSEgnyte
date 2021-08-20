function ConvertFrom-EgnyteGroups {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory,ValueFromPipeline)]
	[AllowNull()]
	[hashtable]$Groups,
	[Parameter(Mandatory)]
	[AllowEmptyCollection()]
	[array]$Permissions
    )

    $GroupObjects = @()

    foreach ($Name in $Groups.keys) {
	$GroupObj = New-Object PSObject
	$GroupObj | Add-Member -MemberType NoteProperty -Name "Name" -Value $Name
	$GroupObj | Add-Member -MemberType NoteProperty -Name "Permissions" -Value $Groups[$Name]
	if ($Permissions.Groups.Name -Contains $Name) {
	    Write-Host -Back Black -Fore Cyan "Already queried $Name group."
	    # only need first element of members array, otherwise this grows exponentially and we run out of memory!
	    $Members = ($Permissions.Groups | ? { $_.Name -eq $Name })[0].Members
	} else {
	    Write-Host -Back Black -Fore Magenta "Getting members of $Name group..."
	    $Members = (Get-ADGroupMembersByName $Name -Quick | ? { $_.Name -notlike '*Template*' }).Name
	}
	if ($Members) {
	    $GroupObj | Add-Member -MemberType NoteProperty -Name "Members" -Value $Members
	}
	$GroupObjects += $GroupObj
    }

    return $GroupObjects
}
