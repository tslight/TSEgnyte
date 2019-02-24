function ConvertFrom-EgnyteGroups {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory,ValueFromPipeline)]
	[AllowNull()]
	[hashtable]$Groups,
	[Parameter(Mandatory)]
	[AllowNull()]
	[hashtable]$Perms
    )

    $GroupObjects = @()
    $Groups = $Groups | Sort-Object -Unique

    foreach ($Name in $Groups.keys) {
	$GroupObj = New-Object PSObject
	$GroupObj | Add-Member -MemberType NoteProperty -Name "Name" -Value $Name
	$GroupObj | Add-Member -MemberType NoteProperty -Name "Permissions" -Value $Groups[$Name]
	if ($Perms.Groups.Keys -Contains $Name) {
	    Write-Host -Back Black -Fore Magenta "Already queried members of $Name group"
	    foreach ($Group in $Perms.Groups.Keys) {
		if ($Group -eq $Name) {
		    $Members = $Group.Members
		}
	    }
	    $Members = $Members | Sort-Object -Unique
	} else {
	    Write-Host -Back Black -Fore Cyan "Getting members of $Name group..."
	    $Members = (Get-ADGroupMembersByName $Name).Name
	}
	if ($Members) {
	    $GroupObj | Add-Member -MemberType NoteProperty -Name "Members" -Value $Members
	}
	$GroupObjects += $GroupObj
    }

    return $GroupObjects
}
